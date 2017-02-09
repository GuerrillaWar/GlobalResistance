class GlobalResistance_StrategyManager extends Object
config(GR_StrategyAssets);

struct SquadMemberDefinition
{
  // use template name OR group name
  var name TemplateName;
  var name GroupName;
  // loadout name optional, assume default if not specified
  var name LoadoutName;
}

struct SquadDefinition
{
  var name ID;
  var array<name> Roles;
  var SquadDefinition Leader;
  var array<SquadDefinitio> Followers;
}



var const config array<SquadDefinition> arrSquadDefinitions;

static function GlobalResistance_StrategyManager GetSingleton () {
  return GlobalResistance_StrategyManager(
    class'XComEngine'.static.GetClassDefaultObject(
      class'GlobalResistance_StrategyManager'
    )
  );
}

