class GlobalResistance_GameState_StrategyAsset extends XComGameState_GeoscapeEntity;

struct StrategyAssetStructure
{
  var name Type;
  var int BuildHoursRemaining;
  var int NextUpkeepTick;
  var array<int> NextProductionTick;
};

struct StrategyAssetSquad
{
  var array<name> GenericUnits;  // stored in character template name only
  var array<StateObjectReference> UniqueUnits; // stored as references to actual Unit States
};

struct StrategyAssetWaypoint
{
  var name Speed;
  var Vector Location; 
};

var() array<StrategyAssetStructure> Structures;
var() array<StrategyAssetSquad> Squads;
var() array<StateObjectReference> Inventory;
var() array<StrategyAssetWaypoint> Waypoints;
var() Vector Destination;
var() Vector Velocity;

// investigate plot storage heeyah

var() protected name                      m_TemplateName;
var() protected GlobalResistance_StrategyAssetTemplate    m_AssetTemplate;

static function GlobalResistance_GameState_StrategyAsset CreateAssetFromTemplate(XComGameState NewGameState, name TemplateName)
{
  local GlobalResistance_StrategyAssetTemplate Template;
  local GlobalResistance_GameState_StrategyAsset Asset;

  Template = GlobalResistance_StrategyAssetTemplate(
    class'X2StrategyElementTemplateManager'.static
      .GetStrategyElementTemplateManager()
      .FindStrategyElementTemplate(TemplateName)
  );

  Asset = GlobalResistance_GameState_StrategyAsset(NewGameState.CreateStateObject(Template.GameStateClass));
  Asset.m_TemplateName = TemplateName;
  Asset.m_AssetTemplate = Template;

  return Asset;
}



//---------------------------------------------------------------------------------------
//----------- GlobalResistance_GameState_StrategyAsset Interface --------------------------------------
//---------------------------------------------------------------------------------------

function int GetStructureCount(name StructureType)
{
  local StrategyAssetStructure Structure;
  local int S_Count;
  foreach Structures(Structure)
  {
    if (Structure.Type == StructureType)
    {
      S_Count++;
    }
  }
  return S_Count;
}

function DestroyStructureOfType(name StructureType)
{
  //local StrategyAssetStructure Structure;
  local int ix;

  ix = Structures.Find('Type', StructureType);
  if (ix != -1)
  {
    Structures.Remove(ix, 1);
  }
}


function GlobalResistance_GameState_MissionSite SpawnMissionSite(name MissionSourceName, name MissionRewardName, optional name ExtraMissionRewardName)
{
  local XComGameStateHistory History;
  local XComGameState NewGameState;
  //local XComGameState_HeadquartersXCom XComHQ;
  local GlobalResistance_GameState_MissionSite MissionState;
  local X2MissionSourceTemplate MissionSource;
  local XComGameState_WorldRegion RegionState;
  local XComGameState_Reward RewardState;
  local array<XComGameState_Reward> MissionRewards;
  local X2RewardTemplate RewardTemplate;
  local X2StrategyElementTemplateManager StratMgr;
  
  History = `XCOMHISTORY;
  //XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
  RegionState = GetWorldRegion();
  StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
  MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate(MissionSourceName));
  RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate(MissionRewardName));

  NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("StrategySite: GenerateMission");
  RewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
  NewGameState.AddStateObject(RewardState);
  RewardState.GenerateReward(NewGameState, , RegionState.GetReference());
  MissionRewards.AddItem(RewardState);

  if(ExtraMissionRewardName != '')
  {
    RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate(ExtraMissionRewardName));

    if(RewardTemplate != none)
    {
      RewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
      NewGameState.AddStateObject(RewardState);
      RewardState.GenerateReward(NewGameState, , RegionState.GetReference());
      MissionRewards.AddItem(RewardState);
    }
  }

  MissionState = GlobalResistance_GameState_MissionSite(NewGameState.CreateStateObject(class'GlobalResistance_GameState_MissionSite'));
  NewGameState.AddStateObject(MissionState);
  MissionState.BuildMission(MissionSource, Get2DLocation(), RegionState.GetReference(), MissionRewards);
  MissionState.SiteGenerated = true;
  MissionState.RelatedStrategySiteRef = GetReference();

  if(NewGameState.GetNumGameStateObjects() > 0)
  {
    `XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
  }
  else
  {
    History.CleanupPendingGameState(NewGameState);
  }

  return MissionState;
}
//---------------------------------------------------------------------------------------
//----------- XComGameState_GeoscapeEntity Implementation -------------------------------
//---------------------------------------------------------------------------------------

protected function bool CanInteract()
{
  return true;
}

//---------------------------------------------------------------------------------------
function bool AboutToExpire()
{
  return false;
}

function class<UIStrategyMapItem> GetUIClass()
{
  return class'UIStrategyMapItem_Mission';
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
  return StaticMesh(`CONTENT.RequestGameArchetype("UI_3D.Overwold_Final.Council_VIP"));
}

// Scale adjustment for the 3D UI static mesh
function vector GetMeshScale()
{
  local vector ScaleVector;

  ScaleVector.X = 0.8;
  ScaleVector.Y = 0.8;
  ScaleVector.Z = 0.8;

  return ScaleVector;
}

function Rotator GetMeshRotator()
{
  local Rotator MeshRotation;

  MeshRotation.Roll = 0;
  MeshRotation.Pitch = 0;
  MeshRotation.Yaw = 0;

  return MeshRotation;
}

function bool ShouldBeVisible()
{
  return true;
}

//function bool ShowFadedPin()
//{
//  return (bNotAtThreshold || bBuilding);
//}

function bool RequiresSquad()
{
  return true;
}


function UpdateGameBoard()
{
}

simulated function name GetMyTemplateName()
{
  return m_TemplateName;
}

//---------------------------------------------------------------------------------------
static function X2StrategyElementTemplateManager GetMyTemplateManager()
{
  return class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
}

simulated function GlobalResistance_StrategyAssetTemplate GetMyTemplate()
{
  if (m_AssetTemplate == none)
  {
    m_AssetTemplate = GlobalResistance_StrategyAssetTemplate(GetMyTemplateManager().FindStrategyElementTemplate(m_TemplateName));
  }
  return m_AssetTemplate;
}

protected function bool DisplaySelectionPrompt()
{
  local GlobalResistance_UIStrategyAsset kScreen;
  local class<GlobalResistance_UIStrategyAsset> kScreenClass;

  kScreenClass = GetMyTemplate().StrategyUIClass;

  if(!`HQPRES.ScreenStack.GetCurrentScreen().IsA('GlobalResistance_UIStrategyAsset'))
  {
    `log("Loading" @ kScreenClass);
    kScreen = `HQPRES.Spawn(kScreenClass, `HQPRES);
    kScreen.bInstantInterp = false;
    kScreen.StrategyAsset = self;
    `HQPRES.ScreenStack.Push(kScreen);
  }

  if( `GAME.GetGeoscape().IsScanning() )
    `HQPRES.StrategyMap2D.ToggleScan();

  return true;
}

function RemoveEntity(XComGameState NewGameState)
{
  `assert(false);
}

function string GetUIButtonIcon()
{
  return "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_Advent";
}
