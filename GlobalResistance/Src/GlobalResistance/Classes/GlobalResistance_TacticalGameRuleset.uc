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
    local StrategyAssetSquad Squad, BlankSquad;
    local GenericUnitCount UnitCount, BlankUnitCount;
    local Vector ObjectiveLocation, DropLocation;
    local int AlertLevel, ForceLevel, Offset;

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
      VanguardSquads = StrategyAsset.GetInitialSquads();
    }

    Offset = 0;
    ObjectiveLocation = BattleData.MapData.ObjectiveLocation;

    foreach VanguardSquads(Squad)
    {
      DropLocation = ObjectiveLocation;
      DropLocation.X = DropLocation.X + Offset;
      class'GlobalResistance_SquadSpawnManager'.static.SpawnSquad(
        Squad, DropLocation, StartState, false
      );
      Offset = Offset + (96 * 10);
    }
  }
}
