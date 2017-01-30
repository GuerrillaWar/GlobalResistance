// This is an Unreal Script
class GlobalResistance_StrategyStart_RegionAIs extends Object;


static function X2StrategyElementTemplateManager GetMyTemplateManager()
{
  return class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
}


static function SetUpAIs(XComGameState StartState, optional bool bTutorialEnabled = false)
{
  local XComGameState_WorldRegion RegionState;
  local GlobalResistance_GameState_RegionCommandAI CommandAI;

	foreach StartState.IterateByClassType(class'XComGameState_WorldRegion', RegionState)
	{
    CommandAI = GlobalResistance_GameState_RegionCommandAI(
      StartState.CreateStateObject(
        class'GlobalResistance_GameState_RegionCommandAI'
      )
    );

    CommandAI.Team = eTeam_Alien;
    CommandAI.Region = RegionState.GetReference();
    `log("Created RegionAI");

    StartState.AddStateObject(CommandAI);
  }
}
