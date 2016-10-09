class XComGameState_NonstackingReinforcements extends XComGameState_AIReinforcementSpawner config(Reinforcements);

var config bool ImmediateActionsForReinforcements;

static function InitiateReinforcements(
  Name EncounterID, 
  optional int OverrideCountdown, 
  optional bool OverrideTargetLocation,
  optional const out Vector TargetLocationOverride,
  optional int IdealSpawnTilesOffset,
  optional XComGameState IncomingGameState,
  optional bool InKismetInitiatedReinforcements)
{
  local XComGameState_NonstackingReinforcements NewAIReinforcementSpawnerState, ExistingSpawnerState;
  local XComGameState NewGameState;
  local XComTacticalMissionManager MissionManager;
  local ConfigurableEncounter Encounter;
  local XComAISpawnManager SpawnManager;
  local Vector DesiredSpawnLocation;

  local bool ReinforcementsCleared;
  local int TileOffset;

  SpawnManager = `SPAWNMGR;

  MissionManager = `TACTICALMISSIONMGR;
  MissionManager.GetConfigurableEncounter(EncounterID, Encounter);

  if (IncomingGameState == none)
    NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Creating Reinforcement Spawner");
  else
    NewGameState = IncomingGameState;

  // Update AIPlayerData with CallReinforcements data.
  NewAIReinforcementSpawnerState = XComGameState_NonstackingReinforcements(NewGameState.CreateStateObject(class'XComGameState_NonstackingReinforcements'));
  NewAIReinforcementSpawnerState.SpawnInfo.EncounterID = EncounterID;

  if( OverrideCountdown > 0 )
  {
    NewAIReinforcementSpawnerState.Countdown = OverrideCountdown;
  }
  else
  {
    NewAIReinforcementSpawnerState.Countdown = Encounter.ReinforcementCountdown;
  }

  if( OverrideTargetLocation )
  {
    DesiredSpawnLocation = TargetLocationOverride;
  }
  else
  {
    DesiredSpawnLocation = SpawnManager.GetCurrentXComLocation();
  }

  NewAIReinforcementSpawnerState.SpawnInfo.SpawnLocation = SpawnManager.SelectReinforcementsLocation(NewAIReinforcementSpawnerState, DesiredSpawnLocation, IdealSpawnTilesOffset, Encounter.bSpawnViaPsiGate);

  ReinforcementsCleared = false;
  TileOffset = 0;

  NewGameState.AddStateObject(NewAIReinforcementSpawnerState);

  while (!ReinforcementsCleared)
  {
    if (TileOffset > 15)
    {
      // Max tries
      //Discard gamestate and return
      if (IncomingGameState == none)
        `XCOMHISTORY.CleanupPendingGameState(NewGameState);
      return;
    }
    ReinforcementsCleared = true;
    foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_NonstackingReinforcements', ExistingSpawnerState)
    {
      // Must not be same reinforcements object and must be pending for reinforcements
      if (ExistingSpawnerState.ObjectID != NewAIReinforcementSpawnerState.ObjectID && ExistingSpawnerState.Countdown > 0)
      {
        if (NewAIReinforcementSpawnerState.SpawnInfo.SpawnLocation == ExistingSpawnerState.SpawnInfo.SpawnLocation)
        {
          ReinforcementsCleared = false;
          // Move reinforcements away and reroll
          TileOffset++;
          NewAIReinforcementSpawnerState.SpawnInfo.SpawnLocation = SpawnManager.SelectReinforcementsLocation(NewAIReinforcementSpawnerState, DesiredSpawnLocation, IdealSpawnTilesOffset + TileOffset, Encounter.bSpawnViaPsiGate);
          break;
        }
      }
    }
  }

  NewAIReinforcementSpawnerState.bKismetInitiatedReinforcements = InKismetInitiatedReinforcements;

  if (IncomingGameState == none)
    `TACTICALRULES.SubmitGameState(NewGameState);
}


// This is called after this reinforcement spawner has finished construction
function EventListenerReturn OnReinforcementSpawnerCreated(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
  local XComGameState NewGameState;
  local XComGameState_AIReinforcementSpawner NewSpawnerState;
  local X2EventManager EventManager;
  local Object ThisObj;
  local X2CharacterTemplate SelectedTemplate;
  local XComGameState_Player PlayerState;
  local XComGameState_BattleData BattleData;
  local XComGameState_MissionSite MissionSiteState;
  local XComAISpawnManager SpawnManager;
  local int AlertLevel, ForceLevel;
  local XComGameStateHistory History;
  local Name CharTemplateName;
  local X2CharacterTemplateManager CharTemplateManager;

  CharTemplateManager = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();

  SpawnManager = `SPAWNMGR;
  History = `XCOMHISTORY;

  BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));

  ForceLevel = BattleData.GetForceLevel();
  AlertLevel = BattleData.GetAlertLevel();

  if( BattleData.m_iMissionID > 0 )
  {
    MissionSiteState = XComGameState_MissionSite(History.GetGameStateForObjectID(BattleData.m_iMissionID));

    if( MissionSiteState != None && MissionSiteState.SelectedMissionData.SelectedMissionScheduleName != '' )
    {
      AlertLevel = MissionSiteState.SelectedMissionData.AlertLevel;
      ForceLevel = MissionSiteState.SelectedMissionData.ForceLevel;
    }
  }

  // Select the spawning visualization mechanism and build the persistent in-world visualization for this spawner
  NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));
  XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = BuildVisualizationForSpawnerCreation;

  NewSpawnerState = XComGameState_AIReinforcementSpawner(NewGameState.CreateStateObject(class'XComGameState_AIReinforcementSpawner', ObjectID));

  // choose reinforcement spawn location

  // build a character selection that will work at this location
  SpawnManager.SelectPodAtLocation(NewSpawnerState.SpawnInfo, ForceLevel, AlertLevel);

  // explicitly disabled all timed loot from reinforcement groups
  NewSpawnerState.SpawnInfo.bGroupDoesNotAwardLoot = true;

  // determine if the spawning mechanism will be via ATT or PsiGate
  //  A) ATT requires open sky above the reinforcement location
  //  B) ATT requires that none of the selected units are oversized (and thus don't make sense to be spawning from ATT)
  NewSpawnerState.UsingPsiGates = NewSpawnerState.SpawnInfo.bForceSpawnViaPsiGate || !DoesLocationSupportATT(NewSpawnerState.SpawnInfo.SpawnLocation);

  if( !NewSpawnerState.UsingPsiGates )
  {
    // determine if we are going to be using psi gates or the ATT based on if the selected templates support it
    foreach NewSpawnerState.SpawnInfo.SelectedCharacterTemplateNames(CharTemplateName)
    {
      SelectedTemplate = CharTemplateManager.FindCharacterTemplate(CharTemplateName);

      if( !SelectedTemplate.bAllowSpawnFromATT )
      {
        NewSpawnerState.UsingPsiGates = true;
        break;
      }
    }
  }

  NewGameState.AddStateObject(NewSpawnerState);

  `TACTICALRULES.SubmitGameState(NewGameState);


  // no countdown specified, spawn reinforcements immediately
  if( Countdown <= 0 )
  {
    NewSpawnerState.SpawnReinforcements();
  }
  // countdown is active, need to listen for AI Turn Begun in order to tick down the countdown
  else
  {
    EventManager = `XEVENTMGR;
    ThisObj = self;

    if (ImmediateActionsForReinforcements)
    {
      // spawn reinforcements on the END of the player turn instead, causing the reinforcements to immediately have AP.
      foreach History.IterateByClassType(class'XComGameState_Player', PlayerState)
      {
        if( PlayerState.GetTeam() == eTeam_XCom )
        {
          EventManager.RegisterForEvent(ThisObj, 'PlayerTurnEnded', OnTurnBegun, ELD_OnStateSubmitted, , PlayerState);
          break;
        }
      }
    }
    else
    {
      PlayerState = `BATTLE.GetAIPlayerState();
      EventManager.RegisterForEvent(ThisObj, 'PlayerTurnBegun', OnTurnBegun, ELD_OnStateSubmitted, , PlayerState);
    }
  }

  return ELR_NoInterrupt;
}

// required due to privacy in base class
function bool DoesLocationSupportATT(Vector TargetLocation)
{
  local TTile TargetLocationTile;
  local TTile AirCheckTile;
  local VoxelRaytraceCheckResult CheckResult;
  local XComWorldData WorldData;

  WorldData = `XWORLD;

    TargetLocationTile = WorldData.GetTileCoordinatesFromPosition(TargetLocation);
  AirCheckTile = TargetLocationTile;
  AirCheckTile.Z = WorldData.NumZ - 1;

  // the space is free if the raytrace hits nothing
  return (WorldData.VoxelRaytrace_Tiles(TargetLocationTile, AirCheckTile, CheckResult) == false);
}
