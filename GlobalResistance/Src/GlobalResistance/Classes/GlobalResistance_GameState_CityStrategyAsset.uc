class GlobalResistance_GameState_CityStrategyAsset extends GlobalResistance_GameState_StrategyAsset;

var() protected name                                 m_CityTemplateName;
var() protected{mutable} transient GlobalResistance_CityTemplate    m_CityTemplate;

var() TDateTime NextDispatch;

function LoadCityTemplate(GlobalResistance_CityTemplate Template)
{
  Location = Template.Location;
  m_CityTemplateName = Template.DataName;
  m_CityTemplate = Template;
  SetNextDispatch();
}

function SetNextDispatch()
{
  NextDispatch = GetCurrentTime();
  class'X2StrategyGameRulesetDataStructures'.static.AddHours(NextDispatch, 48);
  `log("Next Dispatch for" @ GetCityDisplayName() @ " - " @
    class'X2StrategyGameRulesetDataStructures'.static.GetTimeString(NextDispatch)
  );
}

function StaticMesh GetStaticMesh()
{
  if (m_TemplateName == 'StrategyAsset_CityControlZone')
  {
    return StaticMesh(`CONTENT.RequestGameArchetype("UI_3D.Overworld.Council_Icon"));
  }
  else
  {
    return StaticMesh(`CONTENT.RequestGameArchetype("Strat_HoloOverworld.CityPlane"));
  }
}

function GlobalResistance_CityTemplate GetCityTemplate()
{
  if (m_CityTemplate == none)
  {
    m_CityTemplate = GlobalResistance_CityTemplate(GetMyTemplateManager().FindStrategyElementTemplate(m_CityTemplateName));
  }
  return m_CityTemplate;
}

function String GetCityDisplayName()
{
  return GetCityTemplate().DisplayName;
}

function UpdateGameBoard()
{
	local XComGameState NewGameState;
	local GlobalResistance_GameState_CityStrategyAsset NewCityState;
	local bool bSuccess;

	if (ShouldUpdate())
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState( "Send Convoy" );

		NewCityState = GlobalResistance_GameState_CityStrategyAsset(
      NewGameState.CreateStateObject(
        class'GlobalResistance_GameState_CityStrategyAsset', ObjectID
      )
    );
		NewGameState.AddStateObject( NewCityState );

		bSuccess = NewCityState.Update(NewGameState);
		`assert( bSuccess ); // why did Update & ShouldUpdate return different bools?

		`XCOMGAME.GameRuleset.SubmitGameState( NewGameState );
	}
}


function bool ShouldUpdate( )
{
  if (class'X2StrategyGameRulesetDataStructures'.static.LessThan(NextDispatch, GetCurrentTime()))
  {
    return true;
  }
  return false;
}

function Array<GlobalResistance_GameState_CityStrategyAsset> GetOtherCities (
  XComGameState GameState
) {
  local Array<GlobalResistance_GameState_CityStrategyAsset> Cities;
  local GlobalResistance_GameState_CityStrategyAsset City;

	foreach `XCOMHISTORY.IterateByClassType(class'GlobalResistance_GameState_CityStrategyAsset', City)
	{
    if (City.ObjectID != ObjectID)
    {
      Cities.AddItem(City);
    }
  }

  return Cities;
}

function bool Update(XComGameState NewGameState)
{
  local Array<GlobalResistance_GameState_CityStrategyAsset> Cities;
  local GlobalResistance_GameState_CityStrategyAsset City;
  local GlobalResistance_GameState_StrategyAsset Convoy;
  local int RandomIndex;

  if (class'X2StrategyGameRulesetDataStructures'.static.LessThan(NextDispatch, GetCurrentTime()))
  {
    Cities = GetOtherCities(NewGameState);
    RandomIndex = `SYNC_RAND_STATIC(Cities.Length);
    City = Cities[RandomIndex];

    Convoy = class'GlobalResistance_GameState_StrategyAsset'.static.CreateAssetFromTemplate(NewGameState, 'StrategyAsset_AdventConvoy');
    Convoy.Location = Location;
    Convoy.SetWaypointsToAsset(City, 'Standard');
    NewGameState.AddStateObject(Convoy);
    `log("Adding Convoy: " @ GetCityDisplayName() @ "->" @ City.GetCityDisplayName());

    SetNextDispatch();
    return true;
  }
  return false;
}
