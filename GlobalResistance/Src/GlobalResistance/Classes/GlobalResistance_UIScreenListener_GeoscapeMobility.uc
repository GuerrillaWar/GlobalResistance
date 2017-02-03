class GlobalResistance_UIScreenListener_GeoscapeMobility
extends UIScreenListener;

event OnInit(UIScreen Screen)
{
  local Object ThisObj;
  local UIStrategyMap StratHUD;
  local GlobalResistance_UIStrategy_GeoscapeMobility MobilityHUD;

  StratHUD = UIStrategyMap(Screen);
  ThisObj = self;

  MobilityHUD = StratHUD.Spawn(
    class'GlobalResistance_UIStrategy_GeoscapeMobility', StratHUD
  );
  MobilityHUD.InitPanel('GR_MobilityHUD');
  MobilityHUD.InitMobilityHUD(StratHUD);

// `XEVENTMGR.RegisterForEvent(ThisObj, 'RecoveryTurnSystemUpdate', OnQueueUpdate, ELD_OnStateSubmitted);
}

event OnRemoved(UIScreen Screen)
{
  local Object ThisObj;
  ThisObj = self;
// `XEVENTMGR.UnRegisterFromAllEvents(ThisObj);
}

defaultproperties
{
  ScreenClass = class'UIStrategyMap';
}
