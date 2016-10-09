// This is an Unreal Script

class X2DownloadableContentInfo_GlobalResistance extends X2DownloadableContentInfo Config(Game);

static event OnPostTemplatesCreated()
{
  `log("GlobalResistance :: Present And Correct");
}

static event OnPreMission(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
  local GlobalResistance_MissionLogicListener MissionListener;
  `log("GlobalResistance :: Ensuring presence of tactical game state listeners");

  MissionListener = GlobalResistance_MissionLogicListener(
    `XCOMHISTORY.GetSingleGameStateObjectForClass(
      class'GlobalResistance_MissionLogicListener', true
    )
  );

  if (MissionListener == none)
  {
    MissionListener = GlobalResistance_MissionLogicListener(
      NewGameState.CreateStateObject(class'GlobalResistance_MissionLogicListener')
    );
    NewGameState.AddStateObject(MissionListener);
  }

  MissionListener.RegisterToListen();
}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed. When a new campaign is started the initial state of the world
/// is contained in a strategy start state. Never add additional history frames inside of InstallNewCampaign, add new state objects to the start state
/// or directly modify start state objects
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{
 class'GlobalResistance_StrategyStart_CityStrategyAssets'.static.SetUpCityControlZones(StartState);
}
