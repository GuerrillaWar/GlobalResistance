//---------------------------------------------------------------------------------------
//  FILE:    XComGameState_RegionLink.uc
//  AUTHOR:  Jake Solomon
// 
//           
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------
class GlobalResistance_GameState_Road extends XComGameState_GeoscapeEntity
	config(GameBoard);

var vector WorldLocA;
var vector WorldLocB;
var vector WorldPosA;
var vector WorldPosB;
var float RoadLength;
var bool Connector;
var bool WorldLocationsComputed;

var StateObjectReference StateRefA;
var StateObjectReference StateRefB;


//#############################################################################################
//----------------   INITIALIZATION   ---------------------------------------------------------
//#############################################################################################

//---------------------------------------------------------------------------------------
// Region Links created and activated randomly
static function GlobalResistance_GameState_Road BuildRoad(
  XComGameState StartState,
  XComGameState_GeoscapeEntity From,
  XComGameState_GeoscapeEntity To,
  bool Connects
)
{
  local GlobalResistance_GameState_Road Road;

  Road = GlobalResistance_GameState_Road(
    StartState.CreateStateObject(class'GlobalResistance_GameState_Road')
  );

  // must compute on demand inside GetWorldLocation

  Road.Location = From.Location;
  Road.WorldLocA = From.Location;
  Road.WorldPosA = `EARTH.ConvertEarthToWorld(From.Get2DLocation(), false);
  Road.StateRefA = From.GetReference();
  Road.WorldLocB = To.Location;
  Road.WorldPosB = `EARTH.ConvertEarthToWorld(To.Get2DLocation(), false);
  Road.StateRefB = To.GetReference();
  Road.RoadLength = VSize(Road.WorldPosA - Road.WorldPosB);
  Road.Connector = Connects;
  Road.Location.z = 0.4;
  return Road;
}




//#############################################################################################
//----------------   Geoscape Entity Implementation   -----------------------------------------
//#############################################################################################

function class<UIStrategyMapItem> GetUIClass()
{
	return class'GlobalResistance_UIStrategyMapItem_Road';
}

function string GetUIWidgetFlashLibraryName()
{
	return string(class'UIPanel'.default.LibID);
}

function string GetUIPinImagePath()
{
	return "";
}

// The static mesh for this entities 3D UI
function StaticMesh GetStaticMesh()
{
	return StaticMesh'Strat_HoloOverworld.RegionLinkMesh';
}

// Scale adjustment for the 3D UI static mesh
function vector GetMeshScale()
{
	local vector ScaleVector;
  local GlobalResistance_GameState_Road RoadState;

  RoadState = ComputeWorldLocations();

	ScaleVector.X = RoadState.RoadLength;
	ScaleVector.Y = 1;
	ScaleVector.Z = 1;

	return ScaleVector;
}

function Rotator GetMeshRotator()
{
	local Rotator MeshRotator;
  local GlobalResistance_GameState_Road RoadState;

  RoadState = ComputeWorldLocations();
	MeshRotator = rotator(RoadState.WorldPosB - RoadState.WorldPosA);
	return MeshRotator;
}

function UpdateGameBoard()
{
}

function GlobalResistance_GameState_Road ComputeWorldLocations() {
  local XComGameState_GeoscapeEntity From;
  local XComGameState_GeoscapeEntity To;
  local XComGameState NewGameState;
  local GlobalResistance_GameState_Road RoadState;
  local Vector2D v2Start, v2End;

	if (WorldLocationsComputed)
  {
    return self;
  }

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Compute Road World Locations");
	RoadState = GlobalResistance_GameState_Road(
    NewGameState.CreateStateObject(class'GlobalResistance_GameState_Road', ObjectID)
  );
	NewGameState.AddStateObject(RoadState);

	From = XComGameState_GeoscapeEntity(`XCOMHISTORY.GetGameStateForObjectID(StateRefA.ObjectID));
	To = XComGameState_GeoscapeEntity(`XCOMHISTORY.GetGameStateForObjectID(StateRefB.ObjectID));

	v2Start = From.Get2DLocation();
	v2End = To.Get2DLocation();
	RoadState.WorldPosA = `EARTH.ConvertEarthToWorld(v2Start, false);
	RoadState.WorldPosB = `EARTH.ConvertEarthToWorld(v2End, false);
  RoadState.RoadLength = VSize(RoadState.WorldPosA - RoadState.WorldPosB);
	v2Start = `EARTH.ConvertWorldToEarth(RoadState.WorldPosA);
	Location.X = v2Start.X;
	Location.Y = v2Start.Y;
	RoadState.WorldLocationsComputed = true;

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

	return RoadState;
}

function vector GetWorldLocation()
{
  local GlobalResistance_GameState_Road RoadState;

  RoadState = ComputeWorldLocations();
	return RoadState.WorldPosA;
}


protected function bool CanInteract()
{
	// functionality moved to Haven
	return false;
}

function bool ShouldBeVisible()
{
  return true;
}

DefaultProperties
{

}
