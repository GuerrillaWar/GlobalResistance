// This is an Unreal Script
class GlobalResistance_StrategyStart_CityStrategyAssets extends Object
  config(GameBoard);

struct GlobalResistance_Road
{
  var name FromName;
  var name ToName;
  var bool ConnectsRegions;

	structdefaultproperties
	{
		ConnectsRegion = false
	}
};

struct RoadNodeRef
{
  var name AssetName;
  var GlobalResistance_GameState_StrategyAsset Asset;
};

var const config array<GlobalResistance_Road> arrRoads;

static function X2StrategyElementTemplateManager GetMyTemplateManager()
{
  return class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
}

static function SetUpCityControlZones(XComGameState StartState, optional bool bTutorialEnabled = false)
{
  local GlobalResistance_GameState_WorldRegion RegionState;
  local GlobalResistance_GameState_CityStrategyAsset CCZ;
  local GlobalResistance_GameState_GuardPostAsset GPA;
  local array<X2StrategyElementTemplate> arrCityTemplates;
  local array<X2StrategyElementTemplate> arrGPTemplates;
  local GlobalResistance_Road Road;

  local RoadNodeRef RoadIter, BlankRoadNodeRef;
  local GlobalResistance_GameState_Road RoadAsset;
  local GlobalResistance_GameState_StrategyAsset RoadFrom;
  local GlobalResistance_GameState_StrategyAsset RoadTo;
  local array<RoadNodeRef> RoadNodes;

  //Picking random cities
  local int CityIterations;  
  local GlobalResistance_GuardPostTemplate GPTemplate;
  local array<XComGameState_WorldRegion> CapitalizedRegions;
  local array<GlobalResistance_CityTemplate> PickCitySet;
  local array<GlobalResistance_CityTemplate> PickedCities;
  local bool IsCapital;
  local int Index, RandomIndex;

  arrCityTemplates = GetMyTemplateManager().GetAllTemplatesOfClass(class'GlobalResistance_CityTemplate');
  arrGPTemplates = GetMyTemplateManager().GetAllTemplatesOfClass(class'GlobalResistance_GuardPostTemplate');

  PickCitySet.Length = 0;
  for( Index = 0; Index < arrCityTemplates.Length; ++Index )
  {
    PickCitySet.AddItem(GlobalResistance_CityTemplate(arrCityTemplates[Index]));
  }

  `log("CANDIDATE CITIES: " @ PickCitySet.Length);
  CityIterations = 0;
  PickedCities.Length = 0;

  if(PickCitySet.Length > 0)
  {
    do
    {
      RandomIndex = `SYNC_RAND_STATIC(PickCitySet.Length);
      PickedCities.AddItem(PickCitySet[RandomIndex]);
      PickCitySet.Remove(RandomIndex,1);        
      ++CityIterations;
    }
    until(PickCitySet.Length == 0);
  }
  `log("PICKED CITIES: " @ PickedCities.Length);
  //Create state objects for the cities, and associate them with the region that contains them
  for( Index = 0; Index < PickedCities.Length; ++Index )
  {
    RegionState = GetNearestRegion(StartState, PickedCities[Index].Location);
    //Build the state object and add it to the start state
    //
    
    if (Index == 0) {
      // make me a resistance haven for debug purposes
      class'GlobalResistance_GameState_ResistanceCamp'.static.ActivateCampInRegion(StartState, RegionState);
    }


    if (CapitalizedRegions.Find(RegionState) == -1)
    {
      CCZ = GlobalResistance_GameState_CityStrategyAsset(
        class'GlobalResistance_GameState_StrategyAsset'.static.CreateAssetFromTemplate(StartState, 'StrategyAsset_CityControlZone')
      );
      CapitalizedRegions.AddItem(RegionState);
      IsCapital = true;
    }
    else
    {
      CCZ = GlobalResistance_GameState_CityStrategyAsset(
        class'GlobalResistance_GameState_StrategyAsset'.static.CreateAssetFromTemplate(StartState, 'StrategyAsset_SlumCity')
      );
      IsCapital = false;
    }

    CCZ.LoadCityTemplate(PickedCities[Index]);
    CCZ.Region = RegionState.GetReference();
    CCZ.Continent = RegionState.GetContinent().GetReference();

    if (IsCapital) {
      CCZ.AddStructureOfType('GeneClinic');
      CCZ.AddStructureOfType('GeneClinic');
      CCZ.AddStructureOfType('SupplyCentre');
      CCZ.AddStructureOfType('SupplyCentre');
      CCZ.AddStructureOfType('SupplyCentre');
      CCZ.AddStructureOfType('SupplyCentre');
    } else {
      CCZ.AddStructureOfType('SupplyCentre');
      CCZ.AddStructureOfType('SupplyCentre');
      CCZ.AddStructureOfType('SupplyCentre');
    }

    StartState.AddStateObject(CCZ);
    `log("Added City: " @ CCZ.GetCityDisplayName());

    //Add the city to its region's list of cities
    RoadIter.Asset = CCZ;
    RoadIter.AssetName = CCZ.GetCityTemplateName();
    RoadNodes.AddItem(RoadIter);
    RegionState.Cities.AddItem( CCZ.GetReference() );
    RoadIter = BlankRoadNodeRef;
  }  

  for( Index = 0; Index < arrGPTemplates.Length; ++Index )
  {
    GPTemplate = GlobalResistance_GuardPostTemplate(arrGPTemplates[Index]);
    RegionState = GetNearestRegion(StartState, GPTemplate.Location);
    GPA = GlobalResistance_GameState_GuardPostAsset(
      class'GlobalResistance_GameState_StrategyAsset'.static.CreateAssetFromTemplate(StartState, 'StrategyAsset_GuardPost')
    );
    GPA.LoadGPTemplate(GPTemplate);
    GPA.Region = RegionState.GetReference();
    GPA.Continent = RegionState.GetContinent().GetReference();
    `log("Added GuardPost: " @ GPA.GetGuardPostName());
    StartState.AddStateObject(GPA);

    RoadIter.Asset = GPA;
    RoadIter.AssetName = GPA.GetGuardPostName();
    RoadNodes.AddItem(RoadIter);
    RegionState.GuardPosts.AddItem( GPA.GetReference() );
    RoadIter = BlankRoadNodeRef;
  }

  `log("Adding Roads: " @ default.arrRoads.Length);
  foreach default.arrRoads(Road)
  {
    `log("Build Road between" @ Road.FromName @ " -> " @ Road.ToName);

    foreach RoadNodes(RoadIter)
    {
      if (RoadIter.AssetName == Road.FromName) { RoadFrom = RoadIter.Asset; }
      if (RoadIter.AssetName == Road.ToName) { RoadTo = RoadIter.Asset; }
    }

    RegionState = GetNearestRegion(StartState, RoadFrom.Location);
    RoadAsset = class'GlobalResistance_GameState_Road'.static.BuildRoad(
      StartState, RoadFrom, RoadTo, Road.ConnectsRegions
    );

    RoadAsset.Region = RegionState.GetReference();
    RoadAsset.Continent = RegionState.GetContinent().GetReference();

    RegionState.Roads.AddItem( RoadAsset.GetReference() );
    StartState.AddStateObject(RoadAsset);
  }
}

static function bool InRegion(XComGameState_WorldRegion WorldRegion, Vector2D v2Loc)
{
  local X2WorldRegionTemplate RegionTemplate;
  local TRect Bounds;
  local bool bFoundInRegion;

  bFoundInRegion = false;
  RegionTemplate = WorldRegion.GetMyTemplate();
  Bounds = RegionTemplate.Bounds[0];

  if (v2Loc.x > Bounds.fLeft && v2Loc.x < Bounds.fRight &&
      v2Loc.y > Bounds.fTop && v2Loc.y < Bounds.fBottom)
  {
    bFoundInRegion = true;
  }

  return bFoundInRegion;
}

static function GlobalResistance_GameState_WorldRegion GetNearestRegion(
  XComGameState StartState, Vector vLoc
) {
  local X2WorldRegionTemplate RegionTemplate;
  local float ClosestDist, CheckDist;
  local XComGameState_WorldRegion RegionState, NearestRegion;

  closestDist = 100000000000000000000000;

	foreach StartState.IterateByClassType(class'XComGameState_WorldRegion', RegionState)
	{
    RegionTemplate = RegionState.GetMyTemplate();
    CheckDist = GetDistance(RegionTemplate.LandingLocation, vLoc);

    if (CheckDist < ClosestDist) {
      NearestRegion = RegionState;
      ClosestDist = CheckDist;
    }
  }

  return GlobalResistance_GameState_WorldRegion(NearestRegion);
}

static function float GetDistance(Vector From, Vector To)
{
	local Vector DistVect;

	DistVect = From - To;

	return VSize(DistVect);
}
