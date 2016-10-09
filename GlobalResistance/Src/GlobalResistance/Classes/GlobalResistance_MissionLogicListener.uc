//----------------------------------------------------------------------------
// FILE:    GlobalResistance_MissionLogicListener.uc
// PURPOSE: Config listener for loading mission logic on start.
//----------------------------------------------------------------------------


class GlobalResistance_MissionLogicListener extends XComGameState_BaseObject config(MissionLogic);

struct MissionLogicBinding
{
  var string MissionType;
  var string MissionLogicClass;
};

var const config array<MissionLogicBinding> arrMissionLogicBindings;
var bool bRegistered;

function RegisterToListen()
{
  local Object ThisObj;
  ThisObj = self;

  if (!bRegistered)
  {
    `log("GlobalResistance :: MissionLogicListener Loaded");
    bRegistered = true;
    `XEVENTMGR.RegisterForEvent(ThisObj, 'OnTacticalBeginPlay', LoadRelevantMissionLogic, ELD_Immediate, , , true);
  }
  else
  {
    `log("GlobalResistance :: MissionLogicListener already present");
  }
}

function EventListenerReturn LoadRelevantMissionLogic(Object EventData, Object EventSource, XComGameState NewGameState, name EventID)
{
  local XComGameState_BattleData BattleData;
  local XComGameState_MissionLogic MissionLogic;
  local MissionLogicBinding LogicBinding;
  local class<XComGameState_MissionLogic> MissionLogicClass;
  local string MissionType;

  BattleData = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
  MissionType = BattleData.MapData.ActiveMission.sType;
  foreach arrMissionLogicBindings(LogicBinding)
  {

    if (LogicBinding.MissionType == MissionType || LogicBinding.MissionType == "__all__")
    {
      `log("GlobalResistance :: Mission Logic Loading -" @ LogicBinding.MissionLogicClass @ "for" @ LogicBinding.MissionType);
      MissionLogicClass = class<XComGameState_MissionLogic>(DynamicLoadObject(LogicBinding.MissionLogicClass, class'Class'));

      if (!X2TacticalGameRuleset(`XCOMGAME.GameRuleset).bLoadingSavedGame)
      {
        MissionLogic = XComGameState_MissionLogic(NewGameState.CreateStateObject(MissionLogicClass));
        NewGameState.AddStateObject(MissionLogic);
        MissionLogic.SetupMissionStartState(NewGameState);
      }
      else
      {
        MissionLogic = XComGameState_MissionLogic(`XCOMHISTORY.GetSingleGameStateObjectForClass(MissionLogicClass));
        NewGameState.AddStateObject(MissionLogic);
      }
      MissionLogic.RegisterEventHandlers();
    }
  }
  `log("GlobalResistance :: Loaded Mission Logic");
  return ELR_NoInterrupt;
}
