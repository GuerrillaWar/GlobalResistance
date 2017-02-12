class GlobalResistance_StrategyManager extends Object
config(GR_StrategyAssets);

struct SquadMemberDefinition
{
  // use template name OR group name
  var name TemplateName;
  var name GroupName;
  // loadout name optional, assume default if not specified
  var name LoadoutName;
  var int Count;

  structdefaultproperties
  {
    Count=1;
  }
};

struct SquadDefinition
{
  var name ID;
  var array<name> Roles;
  var SquadMemberDefinition Leader;
  var array<SquadMemberDefinition> Followers;
};



var const config array<SquadDefinition> arrSquadDefinitions;

static function GlobalResistance_StrategyManager GetSingleton () {
  return GlobalResistance_StrategyManager(
    class'XComEngine'.static.GetClassDefaultObject(
      class'GlobalResistance_StrategyManager'
    )
  );
}


function array<SquadDefinition> GetSquadDefinitionsForRole(name Role)
{
  local array<SquadDefinition> ValidDefs;
  local SquadDefinition SquadDef;

  foreach default.arrSquadDefinitions(SquadDef)
  {
    if (SquadDef.Roles.Find(Role) != INDEX_NONE)
    {
      ValidDefs.AddItem(SquadDef);
    }
  }

  return ValidDefs;
}
