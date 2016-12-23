// This is an Unreal Script
class GlobalResistance_StrategyStart_AvatarAssets extends Object;

static function X2StrategyElementTemplateManager GetMyTemplateManager()
{
  return class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
}

static function SetUpAssets(XComGameState StartState, optional bool bTutorialEnabled = false)
{
  local XComGameState_WorldRegion RegionState;
  local array<XComGameState_WorldRegion> AllRegions;

	foreach StartState.IterateByClassType(class'XComGameState_WorldRegion', RegionState)
	{
    AllRegions.AddItem(RegionState);
  }

  AddStrategyAssetToRegion(StartState, 'StrategyAsset_AvatarFacility', AllRegions[`SYNC_RAND_STATIC(AllRegions.Length)]);
  AddStrategyAssetToRegion(StartState, 'StrategyAsset_AvatarFacility', AllRegions[`SYNC_RAND_STATIC(AllRegions.Length)]);
}


static function AddStrategyAssetToRegion(
  XComGameState StartState,
  name AssetName, 
  XComGameState_WorldRegion RegionState
) {
  local GlobalResistance_GameState_StrategyAsset Asset;

  `log("BUILDING" @ AssetName @ "at" @ RegionState.GetMyTemplateName());
  Asset = class'GlobalResistance_GameState_StrategyAsset'
    .static.CreateAssetFromTemplate(StartState, AssetName);

  Asset.Region = RegionState.GetReference();
  Asset.Continent = RegionState.GetContinent().GetReference();
  Asset.SetToRandomLocationInContent(RegionState.GetContinent());
  `log("Location:" @ Asset.Location);
  StartState.AddStateObject(Asset);
}

