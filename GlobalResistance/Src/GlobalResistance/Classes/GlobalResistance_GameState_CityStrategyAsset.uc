class GlobalResistance_GameState_CityStrategyAsset extends GlobalResistance_GameState_StrategyAsset;

var() protected name                                 m_CityTemplateName;
var() protected{mutable} transient GlobalResistance_CityTemplate    m_CityTemplate;

var name GeneClinicName;
var name RecruitmentCentreName;
var name SupplyCentreName;
var() TDateTime NextDispatch;

function LoadCityTemplate(GlobalResistance_CityTemplate Template)
{
  Location = Template.Location;
  m_CityTemplateName = Template.DataName;
  m_CityTemplate = Template;
  SetNextDispatch();
}


function SetNextDispatch()
{
  NextDispatch = GetCurrentTime();
  class'X2StrategyGameRulesetDataStructures'.static.AddHours(NextDispatch, 24 * 4);
  `log("Next Dispatch for" @ GetCityDisplayName() @ " - " @
    class'X2StrategyGameRulesetDataStructures'.static.GetTimeString(NextDispatch)
  );
}

function StaticMesh GetStaticMesh()
{
  if (m_TemplateName == 'StrategyAsset_CityControlZone')
  {
    return StaticMesh(`CONTENT.RequestGameArchetype("UI_3D.Overworld.Council_Icon"));
  }
  else
  {
    return StaticMesh(`CONTENT.RequestGameArchetype("Strat_HoloOverworld.CityPlane"));
  }
}

function GlobalResistance_CityTemplate GetCityTemplate()
{
  if (m_CityTemplate == none)
  {
    m_CityTemplate = GlobalResistance_CityTemplate(GetMyTemplateManager().FindStrategyElementTemplate(m_CityTemplateName));
  }
  return m_CityTemplate;
}

function Name GetCityTemplateName()
{
  return m_CityTemplateName;
}

function String GetCityDisplayName()
{
  return GetCityTemplate().DisplayName;
}


function int GetGeneClinicCount() { return GetStructureCount(default.GeneClinicName); }
function int GetRecruitmentCentreCount() { return GetStructureCount(default.RecruitmentCentreName); }
function int GetSupplyCentreCount() { return GetStructureCount(default.SupplyCentreName); }

function DestroyGeneClinic() { DestroyStructureOfType(default.GeneClinicName); }

function GlobalResistance_GameState_MissionSite GenerateGeneClinicMission()
{
  return SpawnMissionSite('MissionSource_SabotageCCZGeneClinic', 'Reward_None');
}

function GlobalResistance_GameState_MissionSite GenerateMonumentMission()
{
  return SpawnMissionSite('MissionSource_SabotageCCZMonument', 'Reward_None');
}


function Array<StrategyAssetSquad> GetInitialSquads(
  GlobalResistance_GameState_MissionSite MissionSite,
  XComGameState_BattleData BattleData
) {
  local int OnSiteSquadCap;
  local StrategyAssetSquad CandidateSquad, IterSquad;
  local Array<StrategyAssetSquad> InitSquads, SquadPool;
  local GlobalResistance_StrategyAssetTemplate Template;
  local MilitaryRequirement Requirement;
  local StrategyAssetStructureDefinition StructureDef;

  SquadPool = Squads;

  if (m_TemplateName == 'StrategyAsset_CityControlZone')
  {
    OnSiteSquadCap = Round(Squads.Length / (4 + Structures.Length));
  }
  else
  {
    OnSiteSquadCap = Round(Squads.Length / (3 + Structures.Length));
  }

  if (MissionSite.Source == 'MissionSource_SabotageCCZGeneClinic')
  {
    StructureDef = Template.GetStructureDefinition('GeneClinic');
    foreach StructureDef.DefensiveRequirements(Requirement)
    {
      if (BattleData.m_iAlertLevel >= Requirement.AlertLevel)
      {
        CandidateSquad = GetRandomSquadForRole(SquadPool, Requirement.Role);
        if (CandidateSquad.Role != '' && InitSquads.Length < OnSiteSquadCap)
        {
          InitSquads.AddItem(CandidateSquad);
          SquadPool.RemoveItem(CandidateSquad);
        }
      }
    }
  }

  // populate pool with remaining squads
  while (InitSquads.Length < OnSiteSquadCap && SquadPool.Length > 0)
  {
    CandidateSquad = SquadPool[`SYNC_RAND_STATIC(SquadPool.Length)];
    InitSquads.AddItem(CandidateSquad);
    SquadPool.RemoveItem(CandidateSquad);
  }

  return InitSquads;
}


function Array<GlobalResistance_GameState_CityStrategyAsset> GetOtherCities (
  XComGameState GameState
) {
  local Array<GlobalResistance_GameState_CityStrategyAsset> Cities;
  local GlobalResistance_GameState_CityStrategyAsset City;

	foreach `XCOMHISTORY.IterateByClassType(class'GlobalResistance_GameState_CityStrategyAsset', City)
	{
    if (City.ObjectID != ObjectID)
    {
      Cities.AddItem(City);
    }
  }

  return Cities;
}

function bool Update(XComGameState NewGameState)
{
  local Array<GlobalResistance_GameState_CityStrategyAsset> Cities;
  local GlobalResistance_GameState_CityStrategyAsset City;
  local GlobalResistance_GameState_StrategyAsset Convoy;
  local int RandomIndex;

  if (m_TemplateName == 'StrategyAsset_CityControlZone')
  {
    if (class'X2StrategyGameRulesetDataStructures'.static.LessThan(NextDispatch, GetCurrentTime()))
    {
      Cities = GetOtherCities(NewGameState);
      RandomIndex = `SYNC_RAND_STATIC(Cities.Length);
      City = Cities[RandomIndex];

      Convoy = class'GlobalResistance_GameState_StrategyAsset'.static.CreateAssetFromTemplate(NewGameState, 'StrategyAsset_AdventConvoy');
      Convoy.Location = Location;
      Convoy.SetWaypointsToAsset(City, 'Standard');
      NewGameState.AddStateObject(Convoy);
      `log("Adding Convoy: " @ GetCityTemplateName() @ "->" @ City.GetCityTemplateName());

      SetNextDispatch();
      return true;
    }
  }
  return false;
}


defaultproperties
{
  GeneClinicName="GeneClinic"
  RecruitmentCentreName="RecruitmentCentre"
  SupplyCentreName="SupplyCentre"
}

