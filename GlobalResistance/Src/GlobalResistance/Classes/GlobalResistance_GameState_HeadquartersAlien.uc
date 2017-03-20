class GlobalResistance_GameState_HeadquartersAlien
extends XComGameState_HeadquartersAlien
config(GameData);


// #######################################################################################
// -------------------- DOOM -------------------------------------------------------------
// #######################################################################################

//---------------------------------------------------------------------------------------
function int GetCurrentDoom(optional bool bIgnorePending = false, optional bool bIncludeUnavailable = false)
{
  local XComGameStateHistory History;
  local GlobalResistance_GameState_AvatarFacilityStrategyAsset AvatarFacility;
  local int TotalDoom;

  TotalDoom = Doom;
  History = `XCOMHISTORY;

  foreach History.IterateByClassType(
    class'GlobalResistance_GameState_AvatarFacilityStrategyAsset',
    AvatarFacility
  )
  {
    TotalDoom += AvatarFacility.Doom;
  }

  if(!bIgnorePending)
  {
    TotalDoom -= GetPendingDoom();
  }

  return TotalDoom;
}
