class GlobalResistance_TacticalGameRuleset extends X2TacticalGameRuleset config(GlobalResistance);

simulated state CreateTacticalGame
{
  simulated function StartStateSpawnAliens(XComGameState StartState)
  {
    local XComGameState_Player IteratePlayerState;
    local XComGameState_BattleData BattleData;
    local XComGameState_MissionSite MissionSiteState;
    local XComAISpawnManager SpawnManager;
    local XComGameState_AIGroup AIGroup, ExtraAIGroup;
    local XGAIGroup Group;
    local StrategyAssetSquad Squad;
    local GenericUnitCount UnitCount;
    local int AlertLevel, ForceLevel;
    local StateObjectReference Enemy;
    local Vector ObjectiveLocation, DropLocation;
    local XComGameState_AIPlayerData kAIData;

    BattleData = XComGameState_BattleData(CachedHistory.GetGameStateForObjectID(CachedBattleDataRef.ObjectID));

    ForceLevel = BattleData.GetForceLevel();
    AlertLevel = BattleData.GetAlertLevel();

    if( BattleData.m_iMissionID > 0 )
    {
      MissionSiteState = XComGameState_MissionSite(CachedHistory.GetGameStateForObjectID(BattleData.m_iMissionID));

      if( MissionSiteState != None && MissionSiteState.SelectedMissionData.SelectedMissionScheduleName != '' )
      {
        AlertLevel = MissionSiteState.SelectedMissionData.AlertLevel;
        ForceLevel = MissionSiteState.SelectedMissionData.ForceLevel;
      }
    }

    // After spawning, the AI player still needs to sync the data
    foreach StartState.IterateByClassType(class'XComGameState_Player', IteratePlayerState)
    {
      if( IteratePlayerState.TeamFlag == eTeam_Alien )
      {        
        XGAIPlayer( CachedHistory.GetVisualizer(IteratePlayerState.ObjectID) ).UpdateDataToAIGameState(true);
        break;
      }
    }

    UnitCount.Count = 4;
    UnitCount.CharacterTemplate = 'AdvTrooperM1';
    Squad.GenericUnits.AddItem(UnitCount);

    kAIData = XComGameState_AIPlayerData(
      StartState.CreateStateObject(
        class'XComGameState_AIPlayerData',
        XGAIPlayer(`BATTLE.GetAIPlayer()).GetAIDataID()
      )
    );

    ObjectiveLocation = BattleData.MapData.ObjectiveLocation;

    DropLocation = ObjectiveLocation;


    class'GlobalResistance_SquadSpawnManager'.static.SpawnSquad(
      Squad, DropLocation, StartState, kAIData, true
    );

    // After spawning, the AI player still needs to sync the data
    /* foreach StartState.IterateByClassType(class'XComGameState_Player', IteratePlayerState) */
    /* { */
    /*   if( IteratePlayerState.TeamFlag == eTeam_Alien ) */
    /*   { */        
    /*     XGAIPlayer( CachedHistory.GetVisualizer(IteratePlayerState.ObjectID) ).UpdateDataToAIGameState(true); */
    /*     break; */
    /*   } */
    /* } */
  }
}
