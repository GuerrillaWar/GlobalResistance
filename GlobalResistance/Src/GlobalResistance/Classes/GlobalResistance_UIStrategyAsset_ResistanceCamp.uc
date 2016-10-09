class GlobalResistance_UIStrategyAsset_ResistanceCamp extends GlobalResistance_UIStrategyAsset;


//----------------------------------------------------------------------------
// MEMBERS

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
  super.InitScreen(InitController, InitMovie, InitName);

  BuildScreen();
}

simulated function Name GetLibraryID()
{
  return 'Alert_SupplyRaidBlades';
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
    Button1.InitButton('Button0', "Do a thing");

    Button2 = Spawn(class'UIButton', ButtonGroup);
    Button2.SetResizeToText(false);
    Button2.InitButton('Button1', "Do another thing");
  }
}

simulated function BuildScreen()
{
  PlaySFX("Geoscape_Supply_Raid_Popup");
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
  LibraryPanel.MC.BeginFunctionOp("UpdateSupplyRaidInfoBlade");
  LibraryPanel.MC.QueueString("img:///UILibrary_StrategyImages.X2StrategyMap.Alert_Advent_Facility");
  LibraryPanel.MC.QueueString("m_strSupplyMission");
  LibraryPanel.MC.QueueString("Region Display Name");
  LibraryPanel.MC.QueueString("oppahration");
  LibraryPanel.MC.QueueString("m_strMissionObjective");
  LibraryPanel.MC.QueueString("GetObjectiveString");
  LibraryPanel.MC.QueueString("m_strSupplyRaidGreeble");

  // Launch/Help Panel
  LibraryPanel.MC.QueueString("");
  LibraryPanel.MC.QueueString("");
  LibraryPanel.MC.QueueString("");
  LibraryPanel.MC.QueueString("");

  LibraryPanel.MC.EndOp();
}

simulated function BuildOptionsPanel()
{
  LibraryPanel.MC.BeginFunctionOp("UpdateSupplyRaidButtonBlade");
  LibraryPanel.MC.QueueString("m_strSupplyRaidTitleGreeble");
  LibraryPanel.MC.QueueString("GetRaidDesc");
  LibraryPanel.MC.QueueString("m_strLaunchMission");
  LibraryPanel.MC.QueueString("m_strIgnore");
  LibraryPanel.MC.EndOp();

  //Button1.OnClickedDelegate = OnLaunchClicked;
  //Button2.OnClickedDelegate = OnCancelClicked;

  Button3.Hide();
  ConfirmButton.Hide();
}



//-------------- EVENT HANDLING --------------------------------------------------------

//-------------- GAME DATA HOOKUP --------------------------------------------------------
simulated function String GetMissionDescString()
{
  return "Resistance Cell";
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
