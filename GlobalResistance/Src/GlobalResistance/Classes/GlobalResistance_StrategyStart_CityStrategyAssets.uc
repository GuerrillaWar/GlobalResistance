// This is an Unreal Script
class GlobalResistance_StrategyStart_CityStrategyAssets extends Object;

static function X2StrategyElementTemplateManager GetMyTemplateManager()
{
  return class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
}

static function SetUpCityControlZones(XComGameState StartState, optional bool bTutorialEnabled = false)
{
  local XComGameState_WorldRegion RegionState;
  local GlobalResistance_GameState_CityStrategyAsset CCZ;
  local array<X2StrategyElementTemplate> arrCityTemplates;

  //Picking random cities
  local int MaxCityIterations;
  local int CityIterations;  
  local array<XComGameState_WorldRegion> CapitalizedRegions;
  local array<GlobalResistance_CityTemplate> PickCitySet;
  local array<GlobalResistance_CityTemplate> PickedCities;
  local int NumDesired, Index, RandomIndex;

  arrCityTemplates = GetMyTemplateManager().GetAllTemplatesOfClass(class'GlobalResistance_CityTemplate');
  MaxCityIterations = 100;

  PickCitySet.Length = 0;
  for( Index = 0; Index < arrCityTemplates.Length; ++Index )
  {
    PickCitySet.AddItem(GlobalResistance_CityTemplate(arrCityTemplates[Index]));
  }

  `log("CANDIDATE CITIES: " @ PickCitySet.Length);
  NumDesired = 10;
  CityIterations = 0;
  MaxCityIterations = PickCitySet.Length;
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
    if (CapitalizedRegions.Find(RegionState) == -1)
    {
      CCZ = GlobalResistance_GameState_CityStrategyAsset(
        class'GlobalResistance_GameState_StrategyAsset'.static.CreateAssetFromTemplate(StartState, 'StrategyAsset_CityControlZone')
      );
      CapitalizedRegions.AddItem(RegionState);
    }
    else
    {
      CCZ = GlobalResistance_GameState_CityStrategyAsset(
        class'GlobalResistance_GameState_StrategyAsset'.static.CreateAssetFromTemplate(StartState, 'StrategyAsset_SlumCity')
      );
    }

    CCZ.LoadCityTemplate(PickedCities[Index]);
    CCZ.Region = RegionState.GetReference();
    CCZ.Continent = RegionState.GetContinent().GetReference();

    StartState.AddStateObject(CCZ);
    `log("Added City: " @ CCZ.GetCityDisplayName());

    //Add the city to its region's list of cities
    RegionState.Cities.AddItem( CCZ.GetReference() );
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

static function XComGameState_WorldRegion GetNearestRegion(XComGameState StartState, Vector vLoc)
{
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

  return NearestRegion;
}

static function float GetDistance(Vector From, Vector To)
{
	local Vector DistVect;

	DistVect = From - To;

	return VSize(DistVect);
}
