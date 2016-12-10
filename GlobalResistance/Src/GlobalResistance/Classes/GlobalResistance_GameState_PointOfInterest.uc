class GlobalResistance_GameState_PointOfInterest
extends XComGameState_PointOfInterest;

function bool CanBeScanned() {
  return false;
}

function bool ShouldBeVisible() {
  return false;
}

function Spawn(XComGameState NewGameState)
{
  return;
}
