class GlobalResistance_GameState_GuardPostAsset extends GlobalResistance_GameState_StrategyAsset;


var() protected name                                 m_GPTemplateName;
var() protected{mutable}
      transient GlobalResistance_GuardPostTemplate   m_GPTemplate;

function LoadGPTemplate(GlobalResistance_GuardPostTemplate Template)
{
  Location = Template.Location;
  m_GPTemplateName = Template.DataName;
  m_GPTemplate = Template;
}

function name GetGuardPostName()
{
  return m_GPTemplateName;
}
