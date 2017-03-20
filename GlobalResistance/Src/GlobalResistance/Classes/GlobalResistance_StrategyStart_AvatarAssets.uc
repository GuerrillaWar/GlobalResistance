// This is an Unreal Script
class GlobalResistance_StrategyStart_AvatarAssets extends Object
  config(GameBoard)
  dependson(GlobalResistance_GameState_StrategyAsset);

struct GR_AdventInitState
{
  var name AssetName;
  var array<name> Structures;
  var array<ArtifactCost> Inventory;
  var array<GenericUnitCount> Reserves;
};

var const config array<GR_AdventInitState> arrAdventInitStates;


static function X2StrategyElementTemplateManager GetMyTemplateManager()
{
  return class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
}


static function SetUpAssets(XComGameState StartState, optional bool bTutorialEnabled = false)
{
  local XComGameState_WorldRegion RegionState;
  local array<XComGameState_WorldRegion> AllRegions;
  local GlobalResistance_GameState_StrategyAsset Asset;

  foreach StartState.IterateByClassType(class'XComGameState_WorldRegion', RegionState)
  {
    AllRegions.AddItem(RegionState);
  }

  Asset = AddStrategyAssetToRegion(StartState, 'StrategyAsset_AvatarFacility', AllRegions[`SYNC_RAND_STATIC(AllRegions.Length)]);
  Asset = AddStrategyAssetToRegion(StartState, 'StrategyAsset_AvatarFacility', AllRegions[`SYNC_RAND_STATIC(AllRegions.Length)]);
  Asset = AddStrategyAssetToRegion(StartState, 'StrategyAsset_AdventBlacksite', AllRegions[`SYNC_RAND_STATIC(AllRegions.Length)]);
  Asset = AddStrategyAssetToRegion(StartState, 'StrategyAsset_AdventBlacksite', AllRegions[`SYNC_RAND_STATIC(AllRegions.Length)]);
  Asset = AddStrategyAssetToRegion(StartState, 'StrategyAsset_AdventBlacksite', AllRegions[`SYNC_RAND_STATIC(AllRegions.Length)]);
}


static function GlobalResistance_GameState_StrategyAsset AddStrategyAssetToRegion(
  XComGameState StartState,
  name AssetName, 
  XComGameState_WorldRegion RegionState
) {
  local GlobalResistance_GameState_StrategyAsset Asset;
  local array<GR_AdventInitState> CandidateInitStates;
  local GR_AdventInitState IterInitState, InitState;
	local int InitIndex;
	local ArtifactCost InitCost;
	local GenericUnitCount InitUnitCount;
	local name InitStructureName;


  `log("BUILDING" @ AssetName @ "at" @ RegionState.GetMyTemplateName());
  Asset = class'GlobalResistance_GameState_StrategyAsset'
    .static.CreateAssetFromTemplate(StartState, AssetName);

  Asset.Region = RegionState.GetReference();
  Asset.Continent = RegionState.GetContinent().GetReference();
  Asset.SetToRandomLocationInRegion(RegionState);
  `log("Location:" @ Asset.Location);

  foreach default.arrAdventInitStates(IterInitState)
  {
    if (IterInitState.AssetName == AssetName)
    {
      CandidateInitStates.AddItem(IterInitState);
    }
  }

  InitIndex = `SYNC_RAND_STATIC(CandidateInitStates.Length);
  InitState = CandidateInitStates[InitIndex];

  foreach InitState.Structures(InitStructureName)
  {
    Asset.AddStructureOfType(InitStructureName);
  }

  foreach InitState.Inventory(InitCost)
  {
    Asset.PutCostInInventory(StartState, InitCost);
  }

  foreach InitState.Reserves(InitUnitCount)
  {
    Asset.PutUnitCountInReserves(InitUnitCount);
  }

  StartState.AddStateObject(Asset);
  return Asset;
}


static function AddSquadToAsset(GlobalResistance_GameState_StrategyAsset Asset)
{
  local StrategyAssetSquad Squad;
  local GenericUnitCount UnitCount, BlankUnitCount;

  Squad.SquadType = 'BigSquad';
  Squad.Role = 'CoreDefender';

  UnitCount = BlankUnitCount;
  UnitCount.Count = 1;
  UnitCount.CharacterTemplate = 'AdvCaptainM1';
  Squad.GenericUnits.AddItem(UnitCount);

  UnitCount = BlankUnitCount;
  UnitCount.Count = 3;
  UnitCount.CharacterTemplate = 'AdvTrooperM1';
  Squad.GenericUnits.AddItem(UnitCount);

  UnitCount = BlankUnitCount;
  UnitCount.Count = 2;
  UnitCount.CharacterTemplate = 'AdvStunLancerM1';
  Squad.GenericUnits.AddItem(UnitCount);

  Asset.Squads.AddItem(Squad);
}
