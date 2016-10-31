//---------------------------------------------------------------------------------------
//  FILE:    GlobalResistance_GameState_MissionCalendar.uc
//---------------------------------------------------------------------------------------
class GlobalResistance_GameState_MissionCalendar extends XComGameState_MissionCalendar;

static function SetupCalendar(XComGameState StartState)
{
	local XComGameState_MissionCalendar CalendarState;

	CalendarState = XComGameState_MissionCalendar(StartState.CreateStateObject(class'XComGameState_MissionCalendar'));
	StartState.AddStateObject(CalendarState);
  return;
}


// skip updates, never spawn missions
function bool Update(XComGameState NewGameState)
{
	return false;
}

function OnEndOfMonth(XComGameState NewGameState)
{
  return;
}
