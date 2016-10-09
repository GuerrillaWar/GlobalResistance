class GlobalResistance_UIStrategyAsset extends UIMission;

var public GlobalResistance_GameState_StrategyAsset StrategyAsset;

simulated public function FlyToMissionSite(GlobalResistance_GameState_MissionSite MissionSite)
{
  local XComGameState_HeadquartersXCom XComHQ;
  local XComGameState NewGameState;

  XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();

  HQPRES().CAMLookAtEarth( XComHQ.Get2DLocation() );

  CloseScreen();

  if(MissionSite.Region == XComHQ.Region || MissionSite.Region.ObjectID == 0)
  {
    MissionSite.ConfirmSelection();
  }
  else
  {
    NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Store cross continent mission reference");
    XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
    NewGameState.AddStateObject(XComHQ);
    XComHQ.CrossContinentMission = MissionSite.GetReference();
    `XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
    MissionSite.GetWorldRegion().AttemptSelection();
  }
}
