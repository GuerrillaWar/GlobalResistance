class GlobalResistance_GameState_ResistanceCamp extends GlobalResistance_GameState_StrategyAsset;


static function SetUpResistanceCamps(XComGameState StartState, optional bool bTutorialEnabled = false)
{

}

static function ActivateCampInRegion(XComGameState NewGameState, XComGameState_WorldRegion RegionState)
{
  local GlobalResistance_GameState_ResistanceCamp Camp;

  Camp = GlobalResistance_GameState_ResistanceCamp(
      class'GlobalResistance_GameState_StrategyAsset'.static
                                                     .CreateAssetFromTemplate(
        NewGameState, 'StrategyAsset_ResistanceCamp'
      )
  );
  Camp.Region = RegionState.GetReference();
  Camp.Continent = RegionState.GetContinent().GetReference();
  Camp.SetToRandomLocationInContent(RegionState.GetContinent());
  NewGameState.AddStateObject(Camp);
}


function StaticMesh GetStaticMesh()
{
  return StaticMesh(`CONTENT.RequestGameArchetype("UI_3D.Overworld.Haven"));
}


