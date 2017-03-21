class GlobalResistance_TacticalGameRuleset extends X2TacticalGameRuleset config(GlobalResistance);

simulated state CreateTacticalGame
{
  simulated function StartStateSpawnAliens(XComGameState StartState)
  {
    local XComGameState_Player IteratePlayerState;
    local XComGameState_BattleData BattleData;
    local GlobalResistance_GameState_MissionSite MissionSiteState;
    local GlobalResistance_GameState_StrategyAsset StrategyAsset;
    local XComAISpawnManager SpawnManager;
    local Array<StrategyAssetSquad> VanguardSquads;
    local StrategyAssetSquad Squad;
    local Array<Vector> DropLocations;
    local Vector ObjectiveLocation, DropLocation;
    local int AlertLevel, ForceLevel, Offset, OFFSET_SIZE;

    OFFSET_SIZE = 96 * 10;

    BattleData = XComGameState_BattleData(CachedHistory.GetGameStateForObjectID(CachedBattleDataRef.ObjectID));

    ForceLevel = BattleData.GetForceLevel();
    AlertLevel = BattleData.GetAlertLevel();

    if( BattleData.m_iMissionID > 0 )
    {
      MissionSiteState = GlobalResistance_GameState_MissionSite(CachedHistory.GetGameStateForObjectID(BattleData.m_iMissionID));

      if( MissionSiteState != None && MissionSiteState.SelectedMissionData.SelectedMissionScheduleName != '' )
      {
        AlertLevel = MissionSiteState.SelectedMissionData.AlertLevel;
        ForceLevel = MissionSiteState.SelectedMissionData.ForceLevel;
      }
    }

    SpawnManager = `SPAWNMGR;
    SpawnManager.SpawnAllAliens(ForceLevel, AlertLevel, StartState, MissionSiteState);

    // After spawning, the AI player still needs to sync the data
    foreach StartState.IterateByClassType(class'XComGameState_Player', IteratePlayerState)
    {
      if( IteratePlayerState.TeamFlag == eTeam_Alien )
      {        
        XGAIPlayer( CachedHistory.GetVisualizer(IteratePlayerState.ObjectID) ).UpdateDataToAIGameState(true);
        break;
      }
    }

    if (MissionSiteState.RelatedStrategySiteRef.ObjectID != 0)
    {
      StrategyAsset = GlobalResistance_GameState_StrategyAsset(
        CachedHistory.GetGameStateForObjectID(
          MissionSiteState.RelatedStrategySiteRef.ObjectID
        )
      );
      VanguardSquads = StrategyAsset.GetInitialSquads(MissionSiteState, BattleData);
    }

    Offset = 0;
    ObjectiveLocation = BattleData.MapData.ObjectiveLocation;
    DropLocations = GetDropLocations(
      BattleData.MapData.ObjectiveLocation,
      VanguardSquads.Length
    );
    DropLocation = ObjectiveLocation;
    DropLocation.X = DropLocation.X + Offset;

    foreach VanguardSquads(Squad)
    {
      DropLocation = DropLocations[0];
      DropLocations.Remove(0, 1);
      class'GlobalResistance_SquadSpawnManager'.static.SpawnSquad(
        Squad, DropLocation, StartState, false
      );
    }
  }

  // Get Drop Locations
  function Array<Vector> GetDropLocations(Vector ObjectiveLocation, int Count)
  {
    local Array<Vector> DropLocations;
    local Vector DropLocation;
    local float Radius, Arc;
    local int ix, OFFSET_SIZE;

    DropLocations.AddItem(ObjectiveLocation);
    Radius = `XWORLD.WORLD_StepSize * 10;

    DropLocations.AddItem(ObjectiveLocation);

    for (ix=0; ix < Count; ix++) {
      Arc = 2 * Pi / Count * Ix;
      DropLocation = ObjectiveLocation;
      DropLocation.x = ObjectiveLocation.x + Radius * Cos(Arc);
      DropLocation.y = ObjectiveLocation.y + Radius * Sin(Arc);
      DropLocations.AddItem(DropLocation);
    }

    return DropLocations;
  }
}
