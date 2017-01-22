class GlobalResistance_UIStrategyAsset_CityControlZone extends GlobalResistance_UIStrategyAsset;

//----------------------------------------------------------------------------
// MEMBERS

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
  super.InitScreen(InitController, InitMovie, InitName);

  BuildScreen();
}

simulated function FindMission(name MissionSource)
{
  local XComGameStateHistory History;
  local XComGameState_MissionSite MissionState;

  History = `XCOMHISTORY;

  foreach History.IterateByClassType(class'XComGameState_MissionSite', MissionState)
  {
    if( MissionState.Source == MissionSource && MissionState.Available )
    {
      MissionRef = MissionState.GetReference();
    }
  }
}

simulated function Name GetLibraryID()
{
  return 'Alert_GoldenPath';
}

// Override, because we use a DefaultPanel in teh structure. 
simulated function BindLibraryItem()
{
  local Name AlertLibID;
  local UIPanel DefaultPanel;

  AlertLibID = GetLibraryID();
  if( AlertLibID != '' )
  {
    LibraryPanel = Spawn(class'UIPanel', self);
    LibraryPanel.bAnimateOnInit = false;
    LibraryPanel.InitPanel('', AlertLibID);
    LibraryPanel.SetSelectedNavigation();

    DefaultPanel = Spawn(class'UIPanel', LibraryPanel);
    DefaultPanel.bAnimateOnInit = false;
    DefaultPanel.bCascadeFocus = false;
    DefaultPanel.InitPanel('DefaultPanel');
    DefaultPanel.SetSelectedNavigation();

    ConfirmButton = Spawn(class'UIButton', DefaultPanel);
    ConfirmButton.SetResizeToText(false);
    ConfirmButton.InitButton('ConfirmButton', "CONF BUTTON", OnLaunchClicked);

    ButtonGroup = Spawn(class'UIPanel', DefaultPanel);
    ButtonGroup.InitPanel('ButtonGroup', '');

    Button1 = Spawn(class'UIButton', ButtonGroup);
    Button1.SetResizeToText(false);
    Button1.InitButton('Button0', "Sabotage Gene Clinic");

    Button2 = Spawn(class'UIButton', ButtonGroup);
    Button2.SetResizeToText(false);
    Button2.InitButton('Button1', "Sabotage ADVENT Monument");
  }
}

simulated function BuildScreen()
{
  PlaySFX("GeoscapeFanfares_AlienFacility");
  XComHQPresentationLayer(Movie.Pres).CAMSaveCurrentLocation();
  if(bInstantInterp)
  {
    XComHQPresentationLayer(Movie.Pres).CAMLookAtEarth(StrategyAsset.Get2DLocation(), CAMERA_ZOOM, 0);
  }
  else
  {
    XComHQPresentationLayer(Movie.Pres).CAMLookAtEarth(StrategyAsset.Get2DLocation(), CAMERA_ZOOM);
  }
  // Add Interception warning and Shadow Chamber info 
  super.BuildScreen();
}

simulated function BuildMissionPanel()
{
  local GlobalResistance_GameState_CityStrategyAsset CityAsset;

  CityAsset = GlobalResistance_GameState_CityStrategyAsset(StrategyAsset);
  // Send over to flash ---------------------------------------------------
  LibraryPanel.MC.BeginFunctionOp("UpdateGoldenPathInfoBlade");
  LibraryPanel.MC.QueueString("ADVENT Control Zone");
  LibraryPanel.MC.QueueString(CityAsset.GetCityDisplayName());
  LibraryPanel.MC.QueueString("img:///UILibrary_StrategyImages.X2StrategyMap.Alert_Advent_Facility");
  LibraryPanel.MC.QueueString("Relaxed Forces");
  LibraryPanel.MC.QueueString("Capacity");
  LibraryPanel.MC.QueueString(
    "Inventory:" @ CityAsset.CalculateInventoryCapacity() $
    ", Units" @ CityAsset.CalculateUnitCapacity()
  );
  LibraryPanel.MC.QueueString(
    "Supply Centres: " $ CityAsset.GetStructureCount('SupplyCentre') $ "\n" $
    "Gene Clinics: " $ CityAsset.GetStructureCount('GeneClinic')
  );

  LibraryPanel.MC.QueueString("Civilian Sentiment");
  LibraryPanel.MC.QueueString("Neutral");

  LibraryPanel.MC.EndOp();

}

simulated function BuildOptionsPanel()
{
  LibraryPanel.MC.BeginFunctionOp("UpdateGoldenPathIntel");
  LibraryPanel.MC.QueueString("1");
  LibraryPanel.MC.QueueString("2");
  LibraryPanel.MC.QueueString("3");
  LibraryPanel.MC.QueueString("4");
  LibraryPanel.MC.QueueString("5");
  LibraryPanel.MC.EndOp();

  LibraryPanel.MC.BeginFunctionOp("UpdateGoldenPathButtonBlade");
  LibraryPanel.MC.QueueString("XCOM ACTIONS");
  LibraryPanel.MC.QueueString("Sabotage Gene Clinic");
  LibraryPanel.MC.QueueString(class'UIUtilities_Text'.default.m_strGenericCancel);


  //LibraryPanel.MC.QueueString("LOcked");
  //LibraryPanel.MC.QueueString("LOcked Help");
  //LibraryPanel.MC.QueueString("OKELYDOKELY");

  LibraryPanel.MC.EndOp();


  Button1.OnClickedDelegate = OnGeneClinicClicked;
  Button2.OnClickedDelegate = OnMonumentClicked;

  Button1.SetBad(true);
  Button2.SetBad(true);

}

simulated public function OnGeneClinicClicked(UIButton button)
{
  FlyToMissionSite(StrategyAsset.SpawnMissionSite('MissionSource_SabotageCCZGeneClinic', 'Reward_None'));
}

simulated public function OnMonumentClicked(UIButton button)
{
  FlyToMissionSite(StrategyAsset.SpawnMissionSite('MissionSource_SabotageCCZMonument', 'Reward_None'));
}



//-------------- EVENT HANDLING --------------------------------------------------------

//-------------- GAME DATA HOOKUP --------------------------------------------------------
simulated function String GetMissionDescString()
{
  return "ADVENT Control Zone";
}
simulated function bool CanTakeMission()
{
  return true;
}
simulated function EUIState GetLabelColor()
{
  return eUIState_Bad;
}

//==============================================================================

defaultproperties
{
  InputState = eInputState_Consume;
  Package = "/ package/gfxAlerts/Alerts";
}
