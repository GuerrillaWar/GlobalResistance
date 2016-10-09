class GlobalResistance_GameState_CityStrategyAsset extends GlobalResistance_GameState_StrategyAsset;

var() protected name                                 m_CityTemplateName;
var() protected{mutable} transient GlobalResistance_CityTemplate    m_CityTemplate;

function LoadCityTemplate(GlobalResistance_CityTemplate Template)
{
  Location = Template.Location;
  m_CityTemplateName = Template.DataName;
  m_CityTemplate = Template;
}

function StaticMesh GetStaticMesh()
{
  if (m_TemplateName == 'StrategyAsset_CityControlZone')
  {
    return StaticMesh(`CONTENT.RequestGameArchetype("UI_3D.Overworld.Council_Icon"));
  }
  else
  {
    return StaticMesh(`CONTENT.RequestGameArchetype("UI_3D.Overworld.CityLights"));
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

function String GetCityDisplayName()
{
  return GetCityTemplate().DisplayName;
}
