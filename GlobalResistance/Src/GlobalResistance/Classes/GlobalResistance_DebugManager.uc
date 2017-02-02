class GlobalResistance_DebugManager extends Object;

var bool bStrategyShowEconomicStates;
var bool bStrategyShowEconomicSignals;
var bool bStrategyShowInventory;
var bool bStrategyShowForces;

static function GlobalResistance_DebugManager GetSingleton () {
  return GlobalResistance_DebugManager(
    class'XComEngine'.static.GetClassDefaultObject(
      class'GlobalResistance_DebugManager'
    )
  );
}

function StrategyShowEconomicSignals()
{
	bStrategyShowEconomicSignals = !bStrategyShowEconomicSignals;
	bStrategyShowEconomicStates = false;
	bStrategyShowInventory = false;
	bStrategyShowForces = false;
}

function StrategyShowEconomicStates()
{
	bStrategyShowEconomicStates = !bStrategyShowEconomicStates;
	bStrategyShowEconomicSignals = false;
	bStrategyShowInventory = false;
	bStrategyShowForces = false;
}

function StrategyShowInventory()
{
	bStrategyShowEconomicStates = false;
	bStrategyShowEconomicSignals = false;
	bStrategyShowForces = false;
	bStrategyShowInventory = !bStrategyShowInventory;
}

function StrategyShowForces()
{
	bStrategyShowEconomicSignals = false;
	bStrategyShowEconomicStates = false;
	bStrategyShowInventory = false;
	bStrategyShowForces = !bStrategyShowForces;
}
