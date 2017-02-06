class GlobalResistance_UIStrategy_GeoscapeMobility extends UIPanel;

var UIButton OneMinButton, ThirtyMinutesButton, TwelveHoursButton, FlyButton;

function InitMobilityHUD(UIStrategyMap StratHUD)
{
  AnchorBottomLeft();

  OneMinButton = StratHUD.Spawn(class'UIButton', StratHUD);
  OneMinButton.bAnimateOnInit = false;
  OneMinButton.InitButton('GR_OneMinButton', "1 Min", OnSpeedClicked);
  OneMinButton.AnchorBottomLeft();
  OneMinButton.SetPosition(0, -260);

  ThirtyMinutesButton = StratHUD.Spawn(class'UIButton', StratHUD);
  ThirtyMinutesButton.bAnimateOnInit = false;
  ThirtyMinutesButton.InitButton('GR_ThirtyMinutesButton', "30 Mins", OnSpeedClicked);
  ThirtyMinutesButton.AnchorBottomLeft();
  ThirtyMinutesButton.SetPosition(0, -230);

  TwelveHoursButton = StratHUD.Spawn(class'UIButton', StratHUD);
  TwelveHoursButton.bAnimateOnInit = false;
  TwelveHoursButton.InitButton('GR_TwelveHoursButton', "12 Hrs", OnSpeedClicked);
  TwelveHoursButton.AnchorBottomLeft();
  TwelveHoursButton.SetPosition(0, -200);
  
  FlyButton = StratHUD.Spawn(class'UIButton', StratHUD);
  FlyButton.bAnimateOnInit = false;
  FlyButton.InitButton('GR_FlyButton', "Move Avenger", OnFlyClicked);
  FlyButton.AnchorBottomLeft();
  FlyButton.SetPosition(0, -300);

}

function OnSpeedClicked(UIButton Clicked)
{
  local XGGeoscape kGeoscape;
  kGeoscape = `GAME.GetGeoscape();

  if (Clicked.MCName == 'GR_TwelveHoursButton')
  {
    kGeoscape.m_fTimeScale = kGeoscape.TWELVE_HOURS;
  }
  else if (Clicked.MCName == 'GR_ThirtyMinutesButton')
  {
    kGeoscape.m_fTimeScale = kGeoscape.THIRTY_MINUTES;
  }
  else
  {
    kGeoscape.m_fTimeScale = kGeoscape.ONE_MINUTE;
  }
}

function OnFlyClicked(UIButton Clicked)
{
  local GlobalResistance_UIMouseGuard_StrategyMap StrategyMapMouseGuard;

  `log("Awaiting Movement Click");
  StrategyMapMouseGuard = Spawn(
    class'GlobalResistance_UIMouseGuard_StrategyMap',
    `SCREENSTACK.GetCurrentScreen()
  );
  `SCREENSTACK.Push(StrategyMapMouseGuard);
}
