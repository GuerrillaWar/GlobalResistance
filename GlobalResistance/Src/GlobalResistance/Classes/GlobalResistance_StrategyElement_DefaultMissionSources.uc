class GlobalResistance_StrategyElement_DefaultMissionSources
extends X2StrategyElement_DefaultMissionSources config(GameData);


static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> MissionSources;

	MissionSources = super.CreateTemplates();
	MissionSources.AddItem(CreateSabotageCCZMonumentTemplate());
	MissionSources.AddItem(CreateSabotageCCZGeneClinicTemplate());

	return MissionSources;
}

static function X2DataTemplate CreateGuerillaOpTemplate()
{
	local X2MissionSourceTemplate Template;
	local RewardDeckEntry DeckEntry;

	`CREATE_X2TEMPLATE(class'X2MissionSourceTemplate', Template, 'MissionSource_GuerillaOp');
	Template.bIncreasesForceLevel = false;
	Template.bShowRewardOnPin = true;
	Template.OnSuccessFn = GuerillaOpOnSuccess;
	Template.OnFailureFn = GuerillaOpOnFailure;
	Template.OnExpireFn = GuerillaOpOnExpire;
	Template.DifficultyValue = 1;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.GorillaOps";
	Template.MissionImage = "img:///UILibrary_StrategyImages.X2StrategyMap.Alert_Guerrilla_Ops";
	Template.GetMissionDifficultyFn = GetMissionDifficultyFromMonth;
	Template.SpawnMissionsFn = SpawnGuerillaOpsMissions;
	Template.MissionPopupFn = GuerillaOpsPopup;
	Template.WasMissionSuccessfulFn = OneStrategyObjectiveCompleted;

	DeckEntry.RewardName = 'Reward_Supplies';
	DeckEntry.Quantity = 3;
	Template.RewardDeck.AddItem(DeckEntry);
	DeckEntry.RewardName = 'Reward_Scientist';
	DeckEntry.Quantity = 3;
	Template.RewardDeck.AddItem(DeckEntry);
	DeckEntry.RewardName = 'Reward_Engineer';
	DeckEntry.Quantity = 3;
	Template.RewardDeck.AddItem(DeckEntry);
	DeckEntry.RewardName = 'Reward_Soldier';
	DeckEntry.Quantity = 1;
	Template.RewardDeck.AddItem(DeckEntry);
	DeckEntry.RewardName = 'Reward_Intel';
	DeckEntry.Quantity = 2;
	Template.RewardDeck.AddItem(DeckEntry);

	return Template;
}

static function X2DataTemplate CreateRetaliationTemplate()
{
	local X2MissionSourceTemplate Template;

	`CREATE_X2TEMPLATE(class'X2MissionSourceTemplate', Template, 'MissionSource_Retaliation');
	Template.bIncreasesForceLevel = false;
	Template.bDisconnectRegionOnFail = true;
	Template.DifficultyValue = 1;
	Template.OnSuccessFn = RetaliationOnSuccess;
	Template.OnFailureFn = RetaliationOnFailure;
	Template.OnExpireFn = RetaliationOnExpire;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.Retaliation";
	Template.MissionImage = "img:///UILibrary_StrategyImages.X2StrategyMap.Alert_Retaliation";
	Template.GetMissionDifficultyFn = GetMissionDifficultyFromMonth;
	Template.CreateMissionsFn = CreateRetaliationMission;
	Template.SpawnMissionsFn = SpawnRetaliationMission;
	Template.MissionPopupFn = RetaliationPopup;
	Template.WasMissionSuccessfulFn = OneStrategyObjectiveCompleted;

	return Template;
}

static function SetCommonTemplateVars(X2MissionSourceTemplate Template)
{
	Template.bIncreasesForceLevel = false;
	Template.bAlienNetwork = false;
	Template.DifficultyValue = 1;
	Template.bIgnoreDifficultyCap = true;
	Template.GetMissionDifficultyFn = GetMissionDifficultyFromTemplate;
	Template.WasMissionSuccessfulFn = OneStrategyObjectiveCompleted;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.AlienFacility";
	Template.MissionImage = "img:///UILibrary_StrategyImages.X2StrategyMap.Alert_Advent_Facility";
}

static function X2DataTemplate CreateSabotageCCZMonumentTemplate()
{
	local X2MissionSourceTemplate Template;

	`CREATE_X2TEMPLATE(class'X2MissionSourceTemplate', Template, 'MissionSource_SabotageCCZMonument');
	SetCommonTemplateVars(Template);
	Template.OnSuccessFn = CCZMonumentOnSuccess;
	Template.OnFailureFn = CCZMonumentOnFailure;
	return Template;
}

function CCZMonumentOnSuccess(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
  local XComGameState_WorldRegion RegionState;
  RegionState = XComGameState_WorldRegion(`XCOMHISTORY.GetGameStateForObjectID(MissionState.Region.ObjectID));
  class'GlobalResistance_GameState_ResistanceCamp'.static.ActivateCampInRegion(NewGameState, RegionState);
  MissionState.RemoveEntity(NewGameState);
}

function CCZMonumentOnFailure(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	MissionState.RemoveEntity(NewGameState);
}

static function X2DataTemplate CreateSabotageCCZGeneClinicTemplate()
{
	local X2MissionSourceTemplate Template;

	`CREATE_X2TEMPLATE(class'X2MissionSourceTemplate', Template, 'MissionSource_SabotageCCZGeneClinic');
	SetCommonTemplateVars(Template);
	Template.OnSuccessFn = CCZGeneClinicOnSuccess;
	Template.OnFailureFn = CCZGeneClinicOnFailure;
	return Template;
}

function CCZGeneClinicOnSuccess(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
  local GlobalResistance_GameState_CityStrategyAsset CCZ;
  local GlobalResistance_GameState_MissionSite GlobalResistanceMissionState;

  GlobalResistanceMissionState = GlobalResistance_GameState_MissionSite(MissionState);
  CCZ = GlobalResistance_GameState_CityStrategyAsset(NewGameState.CreateStateObject(class'GlobalResistance_GameState_CityStrategyAsset', GlobalResistanceMissionState.RelatedStrategySiteRef.ObjectID));
  CCZ.DestroyGeneClinic();
  NewGameState.AddStateObject(CCZ);
  MissionState.RemoveEntity(NewGameState);
}

function CCZGeneClinicOnFailure(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	MissionState.RemoveEntity(NewGameState);
}
