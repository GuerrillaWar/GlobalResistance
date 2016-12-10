class GlobalResistance_UIStrategyMapItem_Road extends UIStrategyMapItem;

var string CurrentMaterialPath;
var vector CurrentScale;
var vector CurrentLocation;


simulated function UIStrategyMapItem InitMapItem(out XComGameState_GeoscapeEntity Entity)
{
	super.InitMapItem(Entity);
	InitLinkMesh();
  UpdateLinkMesh();

	return self;
}

function UpdateVisuals()
{
	super.UpdateVisuals();
  UpdateLinkMesh();
}

function UpdateLinkMesh()
{
	local MaterialInstanceConstant NewMaterial, NewMIC;
	local Object MaterialObject;
	local XComGameStateHistory History;
	local GlobalResistance_GameState_Road RoadState;
	local XComGameState_WorldRegion RegionStateA, RegionStateB;
	local vector NewScale, NewLocation;
	local string DesiredPath;
	local int idx;
	local float LinkDirection;

	History = `XCOMHISTORY;
  DesiredPath = "Strat_HoloOverworld.MIC_Region_Link_Inactive";

	RoadState = GlobalResistance_GameState_Road(
    History.GetGameStateForObjectID(GeoscapeEntityRef.ObjectID)
  );
	LinkDirection = 0.0;
	NewScale = MapItem3D.GetScale3D();
	NewLocation = RoadState.GetWorldLocation();

  NewScale.Y = 1.0;

	if(DesiredPath != CurrentMaterialPath || NewScale != CurrentScale || NewLocation != CurrentLocation)
	{
		MapItem3D.SetScale3D(NewScale);
		SetLoc(RoadState.Get2DLocation());
		SetLocation(NewLocation);
		MapItem3D.SetLocation(NewLocation);
		CurrentScale = NewScale;
		CurrentLocation = NewLocation;
		CurrentMaterialPath = DesiredPath;
		
		MaterialObject = `CONTENT.RequestGameArchetype(DesiredPath);

		if(MaterialObject != none && MaterialObject.IsA('MaterialInstanceConstant'))
		{
			NewMaterial = MaterialInstanceConstant(MaterialObject);
			NewMIC = new class'MaterialInstanceConstant';
			NewMIC.SetParent(NewMaterial);
			NewMIC.SetScalarParameterValue('RegionLinkLength', RoadState.RoadLength);
			NewMIC.SetScalarParameterValue('ReverseTrace', LinkDirection);
			MapItem3D.SetMeshMaterial(0, NewMIC);
			
			for(idx = 0; idx < MapItem3D.NUM_TILES; idx++)
			{
				MapItem3D.ReattachComponent(MapItem3D.OverworldMeshs[idx]);
			}
		}
	}
}

function InitLinkMesh()
{
	local GlobalResistance_GameState_Road RoadState;
	local Vector Translation;

	RoadState = GlobalResistance_GameState_Road(`XCOMHISTORY.GetGameStateForObjectID(GeoscapeEntityRef.ObjectID));
	Translation = RoadState.GetWorldLocation() - Location;
	Translation.Z = 0.4f;

	MapItem3D.SetMeshTranslation(Translation);
	MapItem3D.SetScale3D(RoadState.GetMeshScale());
	MapItem3D.SetMeshRotation(RoadState.GetMeshRotator());
}

// Handle mouse hover special behavior
simulated function OnMouseIn()
{
}

// Clear mouse hover special behavior
simulated function OnMouseOut()
{
}

defaultproperties
{
	bIsNavigable = false;
}
