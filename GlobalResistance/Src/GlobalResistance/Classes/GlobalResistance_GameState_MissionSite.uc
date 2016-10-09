class GlobalResistance_GameState_MissionSite extends XComGameState_MissionSite;

var() bool SiteGenerated;
var() StateObjectReference RelatedStrategySiteRef;

function bool ShouldBeVisible()
{
  return !SiteGenerated && (Available || bBuilding);
}

function SquadSelectionCancelled()
{
  local XComGameState NewGameState;

  ClearIntelOptions();
  InteractionComplete(true); // RTB after backing out of squad selection

  if (SiteGenerated)
  {
    NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Mission Expired");
    RemoveEntity(NewGameState);
    `XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
  }
}

function CancelMission()
{
  local XComGameState NewGameState;

  ClearIntelOptions();
  ResumePsiOperativeTraining();

  `XSTRATEGYSOUNDMGR.PlayGeoscapeMusic();
  InteractionComplete(true);

  if (SiteGenerated)
  {
    NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Mission Expired");
    RemoveEntity(NewGameState);
    `XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
  }
}
