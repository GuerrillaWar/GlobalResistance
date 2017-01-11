class GlobalResistance_SquadSpawnManager extends Object;

static function SpawnSquad(StrategyAssetSquad Squad, Vector Location, XComGameState GameState, XComGameState_AIPlayerData kAIData, bool bAddToStartState)
{
  local XComAISpawnManager SpawnManager;
  local XComGameState_AIGroup AIGroup;
  local GenericUnitCount UnitCount;
  local XComWorldData WorldData;
  local Name TemplateName;
  local Vector DropLocation;
  local StateObjectReference UnitRef;
  local TTile kTile;
  local int Ix, Offset;

  Offset = 0;
  WorldData = `XWORLD;

  SpawnManager = `SPAWNMGR;

  foreach Squad.GenericUnits(UnitCount)
  {
    for (Ix = 0; Ix < UnitCount.Count; Ix++)
    {
      DropLocation = Location;
      DropLocation.X = DropLocation.X + Offset;
      DropLocation.Y = DropLocation.Y + Offset;
      Offset = Offset + 96;
      `log("Spawning " @ UnitCount.CharacterTemplate @ ", At:" @ DropLocation @ "with" @ Offset);
      UnitRef = SpawnManager.CreateUnit(
        DropLocation, UnitCount.CharacterTemplate, eTeam_Alien, false,
        false, GameState
      );
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
