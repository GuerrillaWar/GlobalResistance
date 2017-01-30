class GlobalResistance_SquadSpawnManager extends Object;

static function SpawnSquad(StrategyAssetSquad Squad, Vector Location, XComGameState GameState, bool bAddToStartState)
{
  local XComAISpawnManager SpawnManager;
  local XComGameState_AIGroup AIGroup;
  local GenericUnitCount UnitCount;
  local XComWorldData WorldData;
  local StateObjectReference UnitRef;
  local Array<TilePosPair> PosCandidates;
  local TilePosPair PosCandidate;
  local XComGameState_AIPlayerData kAIData;
  local bool CandidateValid;
  local int Ix, CandidateCursor;

  WorldData = `XWORLD;

  SpawnManager = `SPAWNMGR;

  WorldData.CollectTilesInCylinder(PosCandidates, Location, 96 * 3, 96 * 1);

  kAIData = XComGameState_AIPlayerData(
    GameState.CreateStateObject(
      class'XComGameState_AIPlayerData',
      XGAIPlayer(`BATTLE.GetAIPlayer()).GetAIDataID()
    )
  );
  `log("BattleAI Data ID" @ XGAIPlayer(`BATTLE.GetAIPlayer()).GetAIDataID());

  foreach Squad.GenericUnits(UnitCount)
  {
    for (Ix = 0; Ix < UnitCount.Count; Ix++)
    {
      CandidateValid = false;
      CandidateCursor = 0;

      while (!CandidateValid && CandidateCursor < PosCandidates.Length)
      {
        PosCandidate = PosCandidates[CandidateCursor];
        CandidateValid = WorldData.CanUnitsEnterTile(PosCandidate.Tile);
        CandidateCursor++;
      }

      `log("Spawning " @ UnitCount.CharacterTemplate @ ", At:" @ PosCandidate.WorldPos);
      UnitRef = SpawnManager.CreateUnit(
        PosCandidate.WorldPos, UnitCount.CharacterTemplate,
        eTeam_Alien, bAddToStartState, false, GameState
      );
      `log("Built Unit" @ UnitRef.ObjectID);
      `log("Has Unit:" @ GameState.GetGameStateForObjectID(UnitRef.ObjectID));
      WorldData.SetTileBlockedByUnitFlag(XComGameState_Unit(
        GameState.GetGameStateForObjectID(UnitRef.ObjectID)
      ));

      if (AIGroup.ObjectID == 0)
      {
        AIGroup = XComGameState_Unit(
          GameState.GetGameStateForObjectID(UnitRef.ObjectID)
        ).GetGroupMembership(GameState);
        `log("Getting group" @ AIGroup.ObjectID);
      }
      else
      {
        kAIData.TransferUnitToGroup(AIGroup.GetReference(), UnitRef, GameState);
        `log("Transferring to group" @ AIGroup.ObjectID);
      }
    }
  }

  GameState.AddStateObject(kAIData);
}
