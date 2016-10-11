class GlobalResistance_GameState_RegionLink
extends XComGameState_RegionLink
config(GameBoard);


struct RegionLinkTraverse {
  var Vector From;
  var Vector To;
};


static function SetUpRegionLinks(XComGameState StartState)
{
  local XComGameState_RegionLink LinkState;
  local XComGameState_WorldRegion RegionState;

  VerifyTemplateLinks();
  CreateAllLinks(StartState);
  // remove randomization, all links exist.
  //RandomizeLinks(StartState);

  foreach StartState.IterateByClassType(class'XComGameState_RegionLink', LinkState)
  {
    RegionState = XComGameState_WorldRegion(StartState.GetGameStateForObjectID(LinkState.LinkedRegions[0].ObjectID));
    LinkState.Location = RegionState.Location;
    LinkState.Location.z = 0.2;
  }
}


static function RegionLinkTraverse GetRegionLinkTraverse(
  XComGameState_WorldRegion RegionFrom,
  XComGameState_WorldRegion RegionTo
) {
  local RegionLinkTraverse Traverse, DefaultTraverse;
  local XComGameState_RegionLink LinkState;
  local GlobalResistance_GameState_RegionLink GLinkState;

  foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_RegionLink', LinkState)
  {
    GLinkState = GlobalResistance_GameState_RegionLink(LinkState);
    if (GLinkState.LinkedRegions[0].ObjectID == RegionFrom.ObjectID &&
        GLinkState.LinkedRegions[1].ObjectID == RegionTo.ObjectID)
    {

      DefaultTraverse = GLinkState.GetStandardTraverse();

      Traverse.From = DefaultTraverse.From;
      Traverse.To = DefaultTraverse.To;
    }
    else
    if (GLinkState.LinkedRegions[1].ObjectID == RegionFrom.ObjectID &&
        GLinkState.LinkedRegions[0].ObjectID == RegionTo.ObjectID)
    {
      DefaultTraverse = GLinkState.GetStandardTraverse();

      Traverse.From = DefaultTraverse.To;
      Traverse.To = DefaultTraverse.From;
    }
  }
  `log("From: " @ Traverse.From);
  `log("To: " @ Traverse.To);

  return Traverse;
}


function RegionLinkTraverse GetStandardTraverse()
{
  local RegionLinkTraverse Traverse;
	local XComGameState_WorldRegion RegionStateA, RegionStateB;
  local Vector PosA, PosB;
	local Vector2D v2Start, v2End;

	RegionStateA = XComGameState_WorldRegion(`XCOMHISTORY.GetGameStateForObjectID(LinkedRegions[0].ObjectID));
	RegionStateB = XComGameState_WorldRegion(`XCOMHISTORY.GetGameStateForObjectID(LinkedRegions[1].ObjectID));

	v2Start = RegionStateA.Get2DLocation();
	v2End = GetClosestWrappedCoordinate(v2Start, RegionStateB.Get2DLocation());
	PosA = `EARTH.ConvertEarthToWorld(v2Start, false);
	PosB = `EARTH.ConvertEarthToWorld(v2End, false);
	PosA = PosA * (1.0f - LinkLocLerp) + PosB * LinkLocLerp;
	v2Start = `EARTH.ConvertWorldToEarth(PosA);

  Traverse.From.x = v2Start.x;
  Traverse.From.y = v2Start.y;
  Traverse.To.x = v2End.x;
  Traverse.To.y = v2End.y;

  return Traverse;
}




function bool ShouldBeVisible()
{
  return true;
}
