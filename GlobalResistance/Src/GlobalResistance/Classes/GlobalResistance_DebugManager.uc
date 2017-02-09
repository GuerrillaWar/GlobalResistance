class GlobalResistance_DebugManager extends Object;


enum StrategyDebugStatus
{
  eStrategyDebugStatus_None,
  eStrategyDebugStatus_EconomicSignals,
  eStrategyDebugStatus_MilitaryStates,
  eStrategyDebugStatus_EconomicStates,
  eStrategyDebugStatus_Inventory,
  eStrategyDebugStatus_Forces,
};

var StrategyDebugStatus eStrategyAssetDebugState;

static function GlobalResistance_DebugManager GetSingleton () {
  return GlobalResistance_DebugManager(
    class'XComEngine'.static.GetClassDefaultObject(
      class'GlobalResistance_DebugManager'
    )
  );
}

function StrategyShowEconomicSignals()
{
	if (eStrategyAssetDebugState == eStrategyDebugStatus_EconomicSignals)
  {
    eStrategyAssetDebugState = eStrategyDebugStatus_None;
  }
  else
  {
    eStrategyAssetDebugState = eStrategyDebugStatus_EconomicSignals;
  }
}

function StrategyShowMilitaryStates()
{
	if (eStrategyAssetDebugState == eStrategyDebugStatus_MilitaryStates)
  {
    eStrategyAssetDebugState = eStrategyDebugStatus_None;
  }
  else
  {
    eStrategyAssetDebugState = eStrategyDebugStatus_MilitaryStates;
  }
}

function StrategyShowEconomicStates()
{
	if (eStrategyAssetDebugState == eStrategyDebugStatus_EconomicStates)
  {
    eStrategyAssetDebugState = eStrategyDebugStatus_None;
  }
  else
  {
    eStrategyAssetDebugState = eStrategyDebugStatus_EconomicStates;
  }
}

function StrategyShowInventory()
{
	if (eStrategyAssetDebugState == eStrategyDebugStatus_Inventory)
  {
    eStrategyAssetDebugState = eStrategyDebugStatus_None;
  }
  else
  {
    eStrategyAssetDebugState = eStrategyDebugStatus_Inventory;
  }
}

function StrategyShowForces()
{
	if (eStrategyAssetDebugState == eStrategyDebugStatus_Forces)
  {
    eStrategyAssetDebugState = eStrategyDebugStatus_None;
  }
  else
  {
    eStrategyAssetDebugState = eStrategyDebugStatus_Forces;
  }
}
