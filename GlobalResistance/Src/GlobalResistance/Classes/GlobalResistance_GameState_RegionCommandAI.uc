class GlobalResistance_GameState_RegionCommandAI
extends XComGameState_BaseObject
dependson(GlobalResistance_StrategyAssetTemplate,
          GlobalResistance_StrategyManager,
          GlobalResistance_GameState_StrategyAsset);


enum NeedStatus
{
  eNeedStatus_Unfulfilled,
  eNeedStatus_Dispatched,
  eNeedStatus_Fulfilled,
};


struct EconomicTrend
{
  var int ChangePerWeek;
  var int Quantity;
  var name ItemTemplateName;
};


struct MilitaryStatus
{
  var int QuantityNeeded;
  var int Quantity;
  var name Role;
};


struct EconomicNeed
{
  var int Quantity;
  var int QuantityDispatched;
  var name ItemTemplateName;
  var int Runway; // time before need is critical
  var int AssetObjectID;
  var array<int> DispatchIDs;
  var NeedStatus Status;
};


struct MilitaryNeed
{
  var int Quantity;
  var int QuantityDispatched;
  var name Role;
  var int AssetObjectID;
  var array<int> DispatchIDs;
  var NeedStatus Status;
};

struct MilitarySquadAvailability
{
  var int Quantity;
  var name Role;
  var int AssetObjectID;
};

struct MilitaryReserveAvailability
{
  var int Quantity;
  var name CharacterTemplate;
  var int AssetObjectID;
};

struct EconomicAvailability
{
  var int Quantity;
  var name ItemTemplateName;
  var int Runway;
  var int AssetObjectID;
};


var eTeam Team;
var TDateTime NextAITick;
var StateObjectReference    Region;
var array<EconomicNeed> EconomicNeeds;
var array<EconomicAvailability> EconomicAvailabilities;
var array<MilitaryNeed> MilitaryNeeds;
var array<MilitarySquadAvailability> MilitarySquadAvailabilities;
var array<MilitaryReserveAvailability> MilitaryReserveAvailabilities;


function PushNextAITick ()
{
  NextAITick = GetCurrentTime();
  class'X2StrategyGameRulesetDataStructures'.static.AddHours(NextAITick, 72);
}


function AdvanceMilitaryChecks ()
{
  local GlobalResistance_GameState_StrategyAsset Asset;
  local GlobalResistance_StrategyAssetTemplate Template;
  local array<MilitaryStatus> AssetStatus, BlankStatus;
  local MilitaryStatus Status;
  local MilitaryRequirement Requirement;
  local MilitaryNeed Need, BlankNeed;
  local StrategyAssetStructure StructureInstance;
  local StrategyAssetSquad Squad;
  local GlobalResistance_StrategyManager StrategyManager;
  local array<SquadDefinition> ValidSquadDefs;
  local SquadDefinition SquadDef;
  local StrategyAssetStructureDefinition StructureDef;
  local XComGameStateHistory History;
  local int StatusIx, FoundIx, NeedIx, AvailabilityIx;
  local bool IsSurplus, IsDeficit, AbleToCreate;
  History = `XCOMHISTORY;
  StrategyManager = class'GlobalResistance_StrategyManager'.static.GetSingleton();

  foreach History.IterateByClassType(
    class'GlobalResistance_GameState_StrategyAsset', Asset
  )
  {
    if (Asset.Region.ObjectID != Region.ObjectID)
    {
      continue;
    }

    AssetStatus = GetMilitaryStatusOfAsset(Asset);
    Template = Asset.GetMyTemplate();

    `log("Military Status at Asset:" @ Asset.ObjectID);
    foreach AssetStatus(Status, StatusIx)
    {
      `log("- " @ Status.Role @ Status.Quantity $ "/" $ Status.QuantityNeeded);

      AbleToCreate = true;

      while (AbleToCreate && Status.Quantity < Status.QuantityNeeded)
      {
        ValidSquadDefs = StrategyManager.GetSquadDefinitionsForRole(Status.Role);
        foreach ValidSquadDefs(SquadDef)
        {
          if (Asset.CanBuildSquadDefinitionFromReserves(SquadDef))
          {
            `log("Can build" @ SquadDef.ID @ "squad locally");
            Asset.BuildSquadDefinitionFromReserves(SquadDef, Status.Role);
            Status.Quantity += 1;
            AbleToCreate = true;
            break;
          }
          else
          {
            AbleToCreate = false;
          }
        }
      }

      `log("- " @ Status.Role @ Status.Quantity $ "/" $ Status.QuantityNeeded);
      AssetStatus[StatusIx].Quantity = Status.Quantity;
    }

    // can build squad, if can build squad

    // see if we can satisfy needs directly from asset's reserves
    //
    // any remaining then get pushed onto military needs
  }

  /* `log("Economic Needs for RegionCommandAI" @ ObjectID); */
  /* foreach MilitaryNeeds(Need) */
  /* { */
  /*   `log("NEED" @ Need.ItemTemplateName $ "x" $ Need.Quantity @ */
  /*        "->" @ Need.AssetObjectID); */
  /* } */
}


function AdvanceEconomicChecks ()
{
  local GlobalResistance_GameState_StrategyAsset Asset;
  local array<ArtifactCost> AssetInventory;
  local array<EconomicTrend> AssetTrend, BlankTrend;
  local EconomicTrend Trend;
  local EconomicNeed Need, BlankNeed;
  local EconomicAvailability Availability, BlankAvailability;
  local StrategyAssetStructure StructureInstance;
  local StrategyAssetProduction ProductionInstance;
  local StrategyAssetUpkeep UpkeepInstance;
  local XComGameStateHistory History;
  local int TrendIx, FoundIx, NeedIx, AvailabilityIx;
  local bool IsSurplus, IsDeficit;
  History = `XCOMHISTORY;

  foreach History.IterateByClassType(
    class'GlobalResistance_GameState_StrategyAsset', Asset
  )
  {
    if (Asset.Region.ObjectID != Region.ObjectID)
    {
      continue;
    }

    AssetTrend = BlankTrend;

    foreach Asset.Upkeep(UpkeepInstance) { AddUpkeepToTrend(UpkeepInstance, AssetTrend); }
    foreach Asset.Production(ProductionInstance) { AddProductionToTrend(ProductionInstance, AssetTrend); }

    foreach Asset.Structures(StructureInstance)
    {
      foreach StructureInstance.Upkeep(UpkeepInstance) { AddUpkeepToTrend(UpkeepInstance, AssetTrend); }
      foreach StructureInstance.Production(ProductionInstance) { AddProductionToTrend(ProductionInstance, AssetTrend); }
    }

    `log("Economic Trend for Asset:" @ Asset.ObjectID);
    foreach AssetTrend(Trend, TrendIx)
    {
      AssetTrend[TrendIx].Quantity = Asset.GetNumItemInInventory(Trend.ItemTemplateName);
      `log("- " @ Trend.ItemTemplateName @ AssetTrend[TrendIx].Quantity @ Trend.ChangePerWeek);
    }

    foreach AssetTrend(Trend, TrendIx)
    {
      FoundIx = INDEX_NONE;

      IsDeficit = (
        Trend.ChangePerWeek < 0 &&
        Trend.Quantity < Trend.ChangePerWeek * -4
      );

      IsSurplus = (
        Trend.ChangePerWeek > 0 &&
        Trend.Quantity > Trend.ChangePerWeek * 2
      );

      if (IsDeficit)
      {
        foreach EconomicNeeds(Need, NeedIx)
        {
          if (
            Need.AssetObjectID == Asset.ObjectID &&
            Need.ItemTemplateName == Trend.ItemTemplateName
          )
          {
            FoundIx = NeedIx;
          }
        }

        if (FoundIx == INDEX_NONE)
        {
          Need = BlankNeed;
          Need.Quantity = Trend.ChangePerWeek * -4;
          Need.ItemTemplateName = Trend.ItemTemplateName;
          Need.Runway = 0;
          Need.AssetObjectID = Asset.ObjectID;
          Need.Status = eNeedStatus_Unfulfilled;
          EconomicNeeds.AddItem(Need);
        }
      }
      else if (IsSurplus)
      {
        foreach EconomicAvailabilities(Availability, AvailabilityIx)
        {
          if (
            Availability.AssetObjectID == Asset.ObjectID &&
            Availability.ItemTemplateName == Trend.ItemTemplateName
          )
          {
            FoundIx = AvailabilityIx;
          }
        }

        if (FoundIx == INDEX_NONE)
        {
          Availability = BlankAvailability;
          Availability.Quantity = Trend.Quantity;
          Availability.ItemTemplateName = Trend.ItemTemplateName;
          Availability.Runway = 0;
          Availability.AssetObjectID = Asset.ObjectID;
          EconomicAvailabilities.AddItem(Availability);
        }
        else
        {
          EconomicAvailabilities[FoundIx].Quantity = Trend.Quantity;
        }
      }
    }
  }

  `log("Economic Needs for RegionCommandAI" @ ObjectID);
  foreach EconomicNeeds(Need)
  {
    `log("NEED" @ Need.ItemTemplateName $ "x" $ Need.Quantity @
         "->" @ Need.AssetObjectID);
  }

  foreach EconomicAvailabilities(Availability)
  {
    `log("HAS" @ Availability.ItemTemplateName $ "x" $ Availability.Quantity @
         "-" @ Availability.AssetObjectID @ "->");
  }
}


function array<EconomicNeed> GetEconomicNeedsForAssetID (int AssetID)
{
  local array<EconomicNeed> arrNeeds;
  local EconomicNeed Need;

  foreach EconomicNeeds(Need)
  {
    if (Need.AssetObjectID == AssetID) { arrNeeds.AddItem(Need); }
  }

  return arrNeeds;
}


function array<EconomicAvailability> GetEconomicAvailabilitiesForAssetID (int AssetID)
{
  local array<EconomicAvailability> arrAvailabilities;
  local EconomicAvailability Availability;

  foreach EconomicAvailabilities(Availability)
  {
    if (Availability.AssetObjectID == AssetID) {
      arrAvailabilities.AddItem(Availability);
    }
  }

  return arrAvailabilities;
}


function ReportCompletedDispatch(
  XComGameState NewGameState,
  GlobalResistance_GameState_StrategyAsset Destination,
  GlobalResistance_GameState_StrategyAsset Source,
  ArtifactCost Transfer
)
{
  local EconomicNeed Need;
  local int FoundIx, NeedIx, DispatchIDIx;

  FoundIx = INDEX_NONE;

  foreach EconomicNeeds(Need, NeedIx)
  {
    if ( 
      Need.AssetObjectID == Destination.ObjectID &&
      Need.ItemTemplateName == Transfer.ItemTemplateName
    )
    {
      EconomicNeeds[NeedIx].DispatchIDs.RemoveItem(Source.ObjectID);
      EconomicNeeds[NeedIx].QuantityDispatched -= Transfer.Quantity;
      EconomicNeeds[NeedIx].Quantity -= Transfer.Quantity;
      if (EconomicNeeds[NeedIx].Quantity <= 0)
      {
        FoundIx = NeedIx;
        EconomicNeeds[NeedIx].Status = eNeedStatus_Fulfilled;
      }
    }
  }

  if (FoundIx != INDEX_NONE)
  {
    EconomicNeeds.Remove(FoundIx, 1);
  }
}


function DispatchConvoys(XComGameState NewGameState)
{
  local EconomicNeed Need;
  local ArtifactCost Transfer;
  local GlobalResistance_GameState_StrategyAsset FromAsset, ToAsset, Convoy;
  local EconomicAvailability Availability;
  local int FoundIx, NeedIx, AvailabilityIx;

  foreach EconomicNeeds(Need, NeedIx)
  {
    if (
      Need.Status != eNeedStatus_Unfulfilled &&
      Need.Quantity > Need.QuantityDispatched
    )
    {
      continue;
    }

    FoundIx = INDEX_NONE;
    foreach EconomicAvailabilities(Availability, AvailabilityIx)
    {
      if (Availability.ItemTemplateName == Need.ItemTemplateName)
      {
        FoundIx = AvailabilityIx;
      }
    }

    if (FoundIx != INDEX_NONE)
    {
      Availability = EconomicAvailabilities[FoundIx];
      FromAsset = GlobalResistance_GameState_StrategyAsset(
        NewGameState.CreateStateObject(class'GlobalResistance_GameState_StrategyAsset',
        Availability.AssetObjectID
      ));
      ToAsset = GlobalResistance_GameState_StrategyAsset(
        NewGameState.CreateStateObject(class'GlobalResistance_GameState_StrategyAsset',
        Need.AssetObjectID
      ));

      Transfer.Quantity = Min(
        Availability.Quantity,
        Need.Quantity - Need.QuantityDispatched
      );
      Transfer.ItemTemplateName = Availability.ItemTemplateName;
      FromAsset.ConsumeArtifactCost(NewGameState, Transfer);

      Convoy = class'GlobalResistance_GameState_StrategyAsset'.static.CreateAssetFromTemplate(
        NewGameState, 'StrategyAsset_AdventConvoy'
      );
      Convoy.Location = FromAsset.Location;
      Convoy.PutCostInInventory(NewGameState, Transfer);
      Convoy.SetWaypointsToAsset(ToAsset, 'Standard', 'DeliverAndDisband');
      NewGameState.AddStateObject(Convoy);

      EconomicNeeds[NeedIx].QuantityDispatched += Transfer.Quantity;
      if (EconomicNeeds[NeedIx].QuantityDispatched >= Need.Quantity)
      {
        EconomicNeeds[NeedIx].Status = eNeedStatus_Dispatched;
      }
      EconomicNeeds[NeedIx].DispatchIDs.AddItem(Convoy.ObjectID);

      EconomicAvailabilities.Remove(FoundIx, 1);
    }
  }
}


function AddUpkeepToTrend(
  StrategyAssetUpkeep Upkeep,
  out array<EconomicTrend> Trends
)
{
  local ArtifactCost Cost;
  local EconomicTrend Trend, BlankTrend;
  local int TrendIx;
  local float ChangePerWeek;

  foreach Upkeep.Cost(Cost)
  {
    TrendIx = Trends.Find('ItemTemplateName', Cost.ItemTemplateName);
    ChangePerWeek = Round(
      (168.0 / Upkeep.UpkeepFrequency) * Cost.Quantity * -1
    );
    if (TrendIx == INDEX_NONE)
    {
      Trend = BlankTrend;
      Trend.ChangePerWeek = ChangePerWeek;
      Trend.ItemTemplateName = Cost.ItemTemplateName;
      Trends.AddItem(Trend);
    }
    else
    {
      Trends[TrendIx].ChangePerWeek += ChangePerWeek;
    }
  }
}


function array<MilitaryStatus> GetMilitaryStatusOfAsset(
  GlobalResistance_GameState_StrategyAsset Asset
)
{
  local GlobalResistance_StrategyAssetTemplate Template;
  local array<MilitaryStatus> AssetStatus, BlankStatus;
  local MilitaryStatus Status;
  local MilitaryRequirement Requirement;
  local MilitaryNeed Need, BlankNeed;
  local StrategyAssetStructure StructureInstance;
  local StrategyAssetStructureDefinition StructureDef;
  local StrategyAssetSquad Squad;

  Template = Asset.GetMyTemplate();

  foreach Template.MilitaryRequirements(Requirement)
  {
    AddMilitaryRequirementToStatus(Requirement, AssetStatus, 1);
  }

  foreach Asset.Structures(StructureInstance)
  {
    StructureDef = Template.GetStructureDefinition(StructureInstance.Type);
    foreach StructureDef.DefensiveRequirements(Requirement)
    {
      AddMilitaryRequirementToStatus(Requirement, AssetStatus, 1);
    }
  }

  foreach Asset.Squads(Squad) {
    AddMilitarySquadToStatus(Squad, AssetStatus);
  }

  return AssetStatus;
}




function AddMilitaryRequirementToStatus(
  MilitaryRequirement Requirement,
  out array<MilitaryStatus> AssetStatus,
  int AlertLevel
)
{
  local MilitaryStatus Status;
  local int StatusIx;

  if (AlertLevel < Requirement.AlertLevel) { return; }

  StatusIx = AssetStatus.Find('Role', Requirement.Role);

  if (StatusIx == INDEX_NONE)
  {
    Status.QuantityNeeded = Requirement.Quantity;
    Status.Role = Requirement.Role;
    AssetStatus.AddItem(Status);
  }
  else
  {
    AssetStatus[StatusIx].QuantityNeeded += Requirement.Quantity;
  }
}


function AddMilitarySquadToStatus(
  StrategyAssetSquad Squad,
  out array<MilitaryStatus> AssetStatus
)
{
  local MilitaryStatus Status;
  local int StatusIx;

  StatusIx = AssetStatus.Find('Role', Squad.Role);

  if (StatusIx == INDEX_NONE)
  {
    Status.Quantity = 1;
    Status.Role = Squad.Role;
    AssetStatus.AddItem(Status);
  }
  else
  {
    AssetStatus[StatusIx].Quantity += 1;
  }
}


function AddProductionToTrend(
  StrategyAssetProduction Production,
  out array<EconomicTrend> Trends
)
{
  local ArtifactCost Cost;
  local EconomicTrend Trend, BlankTrend;
  local int TrendIx;
  local float ChangePerWeek;

  foreach Production.Inputs(Cost)
  {
    TrendIx = Trends.Find('ItemTemplateName', Cost.ItemTemplateName);
    ChangePerWeek = Round(
      (168.0 / Production.ProductionTime) * Cost.Quantity * -1
    );
    if (TrendIx == INDEX_NONE)
    {
      Trend = BlankTrend;
      Trend.ChangePerWeek = ChangePerWeek;
      Trend.ItemTemplateName = Cost.ItemTemplateName;
      Trends.AddItem(Trend);
    }
    else
    {
      Trends[TrendIx].ChangePerWeek += ChangePerWeek;
    }
  }


  foreach Production.Outputs(Cost)
  {
    TrendIx = Trends.Find('ItemTemplateName', Cost.ItemTemplateName);
    ChangePerWeek = Round(
      (168.0 / Production.ProductionTime) * Cost.Quantity
    );
    if (TrendIx == INDEX_NONE)
    {
      Trend = BlankTrend;
      Trend.ChangePerWeek = ChangePerWeek;
      Trend.ItemTemplateName = Cost.ItemTemplateName;
      Trends.AddItem(Trend);
    }
    else
    {
      Trends[TrendIx].ChangePerWeek += ChangePerWeek;
    }
  }
}



// #######################################################################################
// -------------------- TIMER HELPERS ----------------------------------------------------
// #######################################################################################

//---------------------------------------------------------------------------------------
function TDateTime GetCurrentTime()
{
	return class'XComGameState_GeoscapeEntity'.static.GetCurrentTime();
}


function Update()
{	
	local XComGameState NewGameState;
  local GlobalResistance_GameState_RegionCommandAI NewAI;

  if (class'X2StrategyGameRulesetDataStructures'.static.LessThan(NextAITick, GetCurrentTime()))
  {
    `log("EconomicCheckRuns RUNS");
    NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("EconomyTickStrategyAsset");
    NewAI = GlobalResistance_GameState_RegionCommandAI(
      NewGameState.CreateStateObject(
        class'GlobalResistance_GameState_RegionCommandAI', ObjectID
      )
    );
    NewAI.AdvanceEconomicChecks();
    NewAI.AdvanceMilitaryChecks();
    NewAI.DispatchConvoys(NewGameState);
    NewAI.NextAITick = GetCurrentTime();
    class'X2StrategyGameRulesetDataStructures'.static.AddHours(NewAI.NextAITick, 72);
    NewGameState.AddStateObject(NewAI);
    `XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
  }
}
