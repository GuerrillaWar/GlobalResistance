class GlobalResistance_DebugManager extends Object;

var bool bStrategyShowEconomicStates;
var bool bStrategyShowInventory;
var bool bStrategyShowForces;

static function GlobalResistance_DebugManager GetSingleton () {
  return GlobalResistance_DebugManager(
    class'XComEngine'.static.GetClassDefaultObject(
      class'GlobalResistance_DebugManager'
    )
  );
}

function StrategyShowEconomicStates()
{
	bStrategyShowEconomicStates = !bStrategyShowEconomicStates;
	bStrategyShowInventory = false;
	bStrategyShowForces = false;
}

function StrategyShowInventory()
{
	bStrategyShowEconomicStates = false;
	bStrategyShowForces = false;
	bStrategyShowInventory = !bStrategyShowInventory;
}

function StrategyShowForces()
{
	bStrategyShowEconomicStates = false;
	bStrategyShowInventory = false;
	bStrategyShowForces = !bStrategyShowForces;
}
