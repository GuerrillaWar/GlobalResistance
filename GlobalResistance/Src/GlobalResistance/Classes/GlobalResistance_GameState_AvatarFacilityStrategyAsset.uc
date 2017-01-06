class GlobalResistance_GameState_AvatarFacilityStrategyAsset extends GlobalResistance_GameState_StrategyAsset;

var() int Doom; // doom attached to this facility

function StaticMesh GetStaticMesh()
{
  return StaticMesh(`CONTENT.RequestGameArchetype("UI_3D.Overwold_Final.AlienFacility"));
}

defaultproperties
{
  Doom = 1
}
