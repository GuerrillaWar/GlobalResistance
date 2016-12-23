class GlobalResistance_GameState_StrategyAsset
extends XComGameState_GeoscapeEntity
dependson(GlobalResistance_StrategyAssetTemplate);

struct StrategyAssetStructure
{
  var name Type;
  var int BuildHoursRemaining;
  var int NextUpkeepTick;
  var array<int> NextProductionTick;
};

struct GenericUnitCount
{
  var int Count;
  var name CharacterTemplate;
};

struct StrategyAssetSquad
{
  var array<GenericUnitCount> GenericUnits;  // stored in character template name only
  var array<StateObjectReference> UniqueUnits; // stored as references to actual Unit States
};

struct StrategyAssetWaypoint
{
  var name Speed;
  var Vector Location; 
  var bool Tracking;
  var StateObjectReference DestinationRef;
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
  `log("Finished Creating Asset:" @ TemplateName);

  return Asset;
}



//---------------------------------------------------------------------------------------
//----------- GlobalResistance_GameState_StrategyAsset Interface --------------------------------------
//---------------------------------------------------------------------------------------
function AddStructureOfType(name StructureType)
{
  local GlobalResistance_StrategyAssetTemplate Template;
  local StrategyAssetStructure Structure;
  local StrategyAssetStructureDefinition StructureDef;
  local StrategyAssetProductionDefinition ProductionDef;

  Template = GetMyTemplate();
  StructureDef = Template.GetStructureDefinition(StructureType);

  Structure.Type = StructureType;
  Structure.BuildHoursRemaining = 0;
  Structure.NextUpkeepTick = StructureDef.UpkeepHours;
  foreach StructureDef.BaseProductionCapability(ProductionDef)
  {
    Structure.NextProductionTick.AddItem(ProductionDef.CycleHours);
  }

  Structures.AddItem(Structure);
}


function AddSquad(StrategyAssetSquad Squad)
{
  Squads.AddItem(Squad);
}


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


function GlobalResistance_GameState_WorldRegion GetNearestWorldRegion()
{
  local X2WorldRegionTemplate RegionTemplate;
  local float ClosestDist, CheckDist;
  local XComGameState_WorldRegion RegionState, NearestRegion;

  closestDist = 100000000000000000000000;

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_WorldRegion', RegionState)
	{
    RegionTemplate = RegionState.GetMyTemplate();
    CheckDist = GetDistance(RegionTemplate.LandingLocation, Location);

    if (CheckDist < ClosestDist) {
      NearestRegion = RegionState;
      ClosestDist = CheckDist;
    }
  }

  return GlobalResistance_GameState_WorldRegion(NearestRegion);
}

function float GetDistance(Vector From, Vector To)
{
	local Vector DistVect;
	DistVect = From - To;
	return VSize(DistVect);
}


function SetWaypointsToAsset (
  GlobalResistance_GameState_StrategyAsset Asset,
  name Speed,
  bool Track = false
) {
  local GlobalResistance_GameState_WorldRegion AssetRegion;
  local XComGameState_WorldRegion PathRegion, LastRegion;
  local X2WorldRegionTemplate RegionTemplate;
  local RegionLinkTraverse Traverse;
  local Array<XComGameState_WorldRegion> RegionChain;

  AssetRegion = Asset.GetNearestWorldRegion();
  RegionChain = GetNearestWorldRegion().FindShortestPathToRegion(AssetRegion);

  `log("Building Path:" @ RegionChain.Length);

  if (RegionChain.Length > 1) {
    foreach RegionChain(PathRegion) {
      if (LastRegion.ObjectID != 0)
      {
        RegionTemplate = PathRegion.GetMyTemplate();
        `log("--" @ RegionTemplate.DisplayName);
        Traverse = class'GlobalResistance_GameState_RegionLink'.static.GetRegionLinkTraverse(
          LastRegion, PathRegion
        );
        AddWaypoint(Traverse.From, Speed);
        AddWaypoint(Traverse.To, Speed);
      }

      LastRegion = PathRegion;

    }
  }

  AddAssetWaypoint(Asset, Speed, Track);
}


function SetToRandomLocationInContent(XComGameState_Continent ContinentState)
{
  Location = ContinentState.GetRandomLocationInContinent(, self);
}


function AddAssetWaypoint (
  GlobalResistance_GameState_StrategyAsset Asset,
  name Speed,
  bool Track = false
) {
  local StrategyAssetWaypoint Waypoint;

  Waypoint.Location = Asset.Location;
  Waypoint.DestinationRef = Asset.GetReference();
  Waypoint.Speed = Speed;
  Waypoint.Tracking = Track;
  
  Waypoints.AddItem(Waypoint);
}

function AddWaypoint (
  Vector WaypointLoc,
  name Speed
) {
  local StrategyAssetWaypoint Waypoint;

  Waypoint.Location = WaypointLoc;
  Waypoint.Speed = Speed;
  Waypoint.Tracking = false;
  Waypoints.AddItem(Waypoint);
}


//---------------------------------------------------------------------------------------
//----------- XComGameState_GeoscapeEntity Implementation -------------------------------
//---------------------------------------------------------------------------------------


protected function bool CanInteract()
{
  return true;
}

function UpdateMovement(float fDeltaT)
{
  local Vector DirectionVector;
  local float DistanceRemaining, TravelDistance;
  local StrategyAssetWaypoint CurrentWaypoint;

  // scale movement by time passage
  fDeltaT *= (`GAME.GetGeoscape().m_fTimeScale / `GAME.GetGeoscape().ONE_HOUR);
  TravelDistance = fDeltaT * 0.005;

  if (Waypoints.Length > 0)
  {
    CurrentWaypoint = Waypoints[0];
    DistanceRemaining = GetDistance(CurrentWaypoint.Location, Location);

    if (DistanceRemaining < TravelDistance)
    {
      // soak up remaining distance and transport to waypoint
      TravelDistance -= DistanceRemaining;
      Location.X = CurrentWaypoint.Location.X;
      Location.Y = CurrentWaypoint.Location.Y;
      Waypoints.RemoveItem(CurrentWaypoint);
    }
  }

  if (Waypoints.Length > 0)
  {
    CurrentWaypoint = Waypoints[0];

    DirectionVector = Normal(CurrentWaypoint.Location - Location);

    // use up remaining travel distance
    Location.X += DirectionVector.X * TravelDistance;
    Location.Y += DirectionVector.Y * TravelDistance;
  }
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
  return StaticMesh(`CONTENT.RequestGameArchetype("UI_3D.Overwold_Final.GorillaOps"));
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
