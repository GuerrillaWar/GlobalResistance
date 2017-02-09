class GlobalResistance_GameState_StrategyAsset
extends XComGameState_GeoscapeEntity
dependson(GlobalResistance_StrategyAssetTemplate);


struct AssetSearchNode
{
  var GlobalResistance_GameState_StrategyAsset Node;
  var int ObjectID;
  var int OptimalSourceID;
  var float Distance;
};


struct GenericUnitCount
{
  var int Count;
  var name CharacterTemplate;
};

struct RecoveringGenericUnit
{
  var TDateTime RecoverTime;
  var GenericUnitCount Units;
};

struct StrategyAssetSquad
{
  var array<GenericUnitCount> GenericUnits;  // stored in character template name only
  var array<StateObjectReference> UniqueUnits; // stored as references to actual Unit States
};


struct StrategyAssetWaypoint
{
  var name Speed;
  var Vector Location; 
  var bool Tracking;
  var StateObjectReference DestinationRef;
  var name DestinationJob;
};

var TDateTime NextEconomyTick;
var array<StrategyAssetProduction> Production;
var array<StrategyAssetUpkeep> Upkeep;
var array<StrategyAssetUpkeepPenalty> UpkeepPenalties;
var array<StrategyAssetStructure> Structures;

var array<StrategyAssetSquad> Squads;
var array<GenericUnitCount> Reserves;
var array<RecoveringGenericUnit> RecoveringReserves;

var array<StateObjectReference> Inventory;
var array<StateObjectReference> ConnectedRoads;
var array<StrategyAssetWaypoint> Waypoints;
var Vector Destination;
var Vector Velocity;

// investigate plot storage heeyah

var protected name                      m_TemplateName;
var protected GlobalResistance_StrategyAssetTemplate    m_AssetTemplate;

static function GlobalResistance_GameState_StrategyAsset CreateAssetFromTemplate(XComGameState NewGameState, name TemplateName)
{
  local GlobalResistance_StrategyAssetTemplate Template;
  local GlobalResistance_GameState_StrategyAsset Asset;

  Template = GlobalResistance_StrategyAssetTemplate(
    class'X2StrategyElementTemplateManager'.static
      .GetStrategyElementTemplateManager()
      .FindStrategyElementTemplate(TemplateName)
  );

  Asset = GlobalResistance_GameState_StrategyAsset(NewGameState.CreateStateObject(Template.GameStateClass));
  Asset.m_TemplateName = TemplateName;
  Asset.m_AssetTemplate = Template;
  if (Template.HasCoreStructure)
  {
    Asset.AddStructureOfType(Template.CoreStructure.ID);
  }
  `log("Finished Creating Asset:" @ TemplateName);

  return Asset;
}


//---------------------------------------------------------------------------------------
//----------- GlobalResistance_GameState_StrategyAsset Interface --------------------------------------
//---------------------------------------------------------------------------------------
function AddStructureOfType(name StructureType)
{
  local StrategyAssetStructure Structure;

  /* Template = GetMyTemplate(); */

  Structure.Type = StructureType;
  Structure.BuildHoursRemaining = 0;
  Structures.AddItem(Structure);
  CalculateProduction();
  CalculateUpkeep();
  UpdateNextEconomyTick();
}


//---------------------------------------------------------------------------------------
//
// INVENTORY MANAGEMENT
//
//---------------------------------------------------------------------------------------
function bool PutItemInInventory(XComGameState AddToGameState, XComGameState_Item ItemState)
{
	local bool AssetModified;
	local XComGameState_Item InventoryItemState, NewInventoryItemState;
	/* local X2ItemTemplate ItemTemplate; */

	/* ItemTemplate = ItemState.GetMyTemplate(); */

  if(!ItemState.GetMyTemplate().bInfiniteItem)
  {
    InventoryItemState = GetItemByName(ItemState.GetMyTemplateName());

    if( InventoryItemState != none)
    {
      AssetModified = false;
      
      if(InventoryItemState.ObjectID != ItemState.ObjectID)
      {
        NewInventoryItemState = XComGameState_Item(AddToGameState.CreateStateObject(class'XComGameState_Item', InventoryItemState.ObjectID));
        NewInventoryItemState.Quantity += ItemState.Quantity;
        AddToGameState.AddStateObject(NewInventoryItemState);
        AddToGameState.RemoveStateObject(ItemState.ObjectID);
      }
    }
    else
    {
      AssetModified = true;
      Inventory.AddItem(ItemState.GetReference());
    }
  }

	return AssetModified;
}


function bool ConsumeArtifactCost(XComGameState GameState, ArtifactCost Cost)
{
	local XComGameState_Item InventoryItemState, NewInventoryItemState;
  InventoryItemState = GetItemByName(Cost.ItemTemplateName);

  if( InventoryItemState != none)
  {
    NewInventoryItemState = XComGameState_Item(GameState.CreateStateObject(class'XComGameState_Item', InventoryItemState.ObjectID));
    NewInventoryItemState.Quantity -= Cost.Quantity;
    GameState.AddStateObject(NewInventoryItemState);
    return true;
  }
  return false;
}


function bool ConsumeAllArtifactCosts(XComGameState GameState, Array<ArtifactCost> Costs)
{
  local bool Successful;
  local int ix;

  for(ix = 0; ix < Costs.Length; ix++)
  {
    Successful = ConsumeArtifactCost(GameState, Costs[ix]);

    if(!Successful)
      break;
  }

  return Successful;
}


function bool CanAffordAllArtifactCosts(Array<ArtifactCost> Costs)
{
  local bool CanAfford;
  local int ix;

  CanAfford = true;

  for(ix = 0; ix < Costs.Length; ix++)
  {
    CanAfford = CanAffordArtifactCost(Costs[ix]);

    if(!CanAfford)
      break;
  }

  return CanAfford;
}


function bool CanAffordArtifactCost(ArtifactCost Cost)
{
  return GetNumItemInInventory(Cost.ItemTemplateName) >= Cost.Quantity;
}

function XComGameState_Item GetItemByName(name ItemTemplateName)
{
	local XComGameStateHistory History;
	local XComGameState_Item InventoryItemState;
	local int i;

	History = `XCOMHISTORY;

	for( i = 0; i < Inventory.Length; i++ )
	{
		InventoryItemState = XComGameState_Item(History.GetGameStateForObjectID(Inventory[i].ObjectId));

		if( InventoryItemState != none && InventoryItemState.GetMyTemplateName() == ItemTemplateName )
		{
			return InventoryItemState;
		}
	}

	return none;
}

function array<ArtifactCost> GetInventoryAsArtifacts()
{
  local array<ArtifactCost> Artifacts;
  local ArtifactCost Artifact;
	local XComGameStateHistory History;
	local XComGameState_Item InventoryItemState;
	local int i;

	History = `XCOMHISTORY;

	for( i = 0; i < Inventory.Length; i++ )
	{
		InventoryItemState = XComGameState_Item(History.GetGameStateForObjectID(Inventory[i].ObjectId));

		if( InventoryItemState != none)
		{
			Artifact.Quantity = InventoryItemState.Quantity;
			Artifact.ItemTemplateName = InventoryItemState.GetMyTemplateName();
      Artifacts.AddItem(Artifact);
		}
	}

	return Artifacts;
}


function int GetNumItemInInventory(name ItemTemplateName)
{
	local XComGameState_Item ItemState;

	ItemState = GetItemByName(ItemTemplateName);
	if (ItemState != none)
	{
		return ItemState.Quantity;
	}

	return 0;
}


// End Inventory
function UpdateNextEconomyTick() {
  local StrategyAssetStructure StructureInstance;
  local StrategyAssetProduction ProductionInstance;
  local StrategyAssetUpkeep UpkeepInstance;
  local TDateTime LowestDateTime;
  LowestDateTime = GetCurrentTime();
  class'X2StrategyGameRulesetDataStructures'.static.AddMonth(LowestDateTime);
  class'X2StrategyGameRulesetDataStructures'.static.AddMonth(LowestDateTime);
  class'X2StrategyGameRulesetDataStructures'.static.AddMonth(LowestDateTime);
  class'X2StrategyGameRulesetDataStructures'.static.AddMonth(LowestDateTime);
  class'X2StrategyGameRulesetDataStructures'.static.AddMonth(LowestDateTime);
  class'X2StrategyGameRulesetDataStructures'.static.AddMonth(LowestDateTime);
  class'X2StrategyGameRulesetDataStructures'.static.AddMonth(LowestDateTime);
  class'X2StrategyGameRulesetDataStructures'.static.AddMonth(LowestDateTime);
  class'X2StrategyGameRulesetDataStructures'.static.AddMonth(LowestDateTime);
  class'X2StrategyGameRulesetDataStructures'.static.AddMonth(LowestDateTime);
  class'X2StrategyGameRulesetDataStructures'.static.AddMonth(LowestDateTime);
  class'X2StrategyGameRulesetDataStructures'.static.AddMonth(LowestDateTime);

  foreach Production(ProductionInstance)
  {
    if (class'X2StrategyGameRulesetDataStructures'.static.LessThan(
      ProductionInstance.NextTick, LowestDateTime
    ))
    {
      LowestDateTime = ProductionInstance.NextTick;
    }
  }

  foreach Upkeep(UpkeepInstance)
  {
    if (class'X2StrategyGameRulesetDataStructures'.static.LessThan(
      UpkeepInstance.NextTick, LowestDateTime
    ))
    {
      LowestDateTime = UpkeepInstance.NextTick;
    }
  }

  foreach Structures(StructureInstance)
  {
    foreach StructureInstance.Production(ProductionInstance)
    {
      if (class'X2StrategyGameRulesetDataStructures'.static.LessThan(
        ProductionInstance.NextTick, LowestDateTime
      ))
      {
        LowestDateTime = ProductionInstance.NextTick;
      }
    }

    foreach StructureInstance.Upkeep(UpkeepInstance)
    {
      if (class'X2StrategyGameRulesetDataStructures'.static.LessThan(
        UpkeepInstance.NextTick, LowestDateTime
      ))
      {
        LowestDateTime = UpkeepInstance.NextTick;
      }
    }
  }

  NextEconomyTick = LowestDateTime;
  `log(
    "Next Economy Tick Set To" @
    class'X2StrategyGameRulesetDataStructures'.static.GetDateString(NextEconomyTick) @
    class'X2StrategyGameRulesetDataStructures'.static.GetTimeString(NextEconomyTick)
  );
}


function bool PutCostInInventory(XComGameState GameState, ArtifactCost Cost)
{
  local X2ItemTemplate ItemTemplate;
  local XComGameState_Item ItemState;
	local X2ItemTemplateManager ItemTemplateManager;

  ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
  ItemTemplate = ItemTemplateManager.FindItemTemplate(Cost.ItemTemplateName);
  ItemState = ItemTemplate.CreateInstanceFromTemplate(GameState);
  ItemState.Quantity = Cost.Quantity;
  GameState.AddStateObject(ItemState);
  return PutItemInInventory(GameState, ItemState);
}


function StrategyAssetProduction AdvanceProduction(
  XComGameState GameState, StrategyAssetProduction ProdInstance
)
{
  local TDateTime NextTick;
  local ArtifactCost Output;
  local X2ItemTemplate ItemTemplate;
  local XComGameState_Item ItemState;
	local X2ItemTemplateManager ItemTemplateManager;

  if (ProdInstance.Currently == eStrategyAssetProductionState_AwaitingInput)
  {
    NextTick = GetCurrentTime();
    // consume resources for input (if possible)
    if (CanAffordAllArtifactCosts(ProdInstance.Inputs))
    {
      ConsumeAllArtifactCosts(GameState, ProdInstance.Inputs);
      ProdInstance.Currently = eStrategyAssetProductionState_Building;
      class'X2StrategyGameRulesetDataStructures'.static.AddHours(
        NextTick, ProdInstance.ProductionTime
      );
    }
    else
    {
      // defer next tick for a day, will attempt production again then
      class'X2StrategyGameRulesetDataStructures'.static.AddHours(NextTick, 24);
    }

    ProdInstance.NextTick = NextTick;
  } else {
    ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

    foreach ProdInstance.Outputs(Output)
    {
      ItemTemplate = ItemTemplateManager.FindItemTemplate(Output.ItemTemplateName);
      ItemState = ItemTemplate.CreateInstanceFromTemplate(GameState);
      ItemState.Quantity = Output.Quantity;
      GameState.AddStateObject(ItemState);
      PutItemInInventory(GameState, ItemState);
      `log("Added to Inventory:" @ Output.ItemTemplateName);
      `log("Already in Storage:" @ GetNumItemInInventory(Output.ItemTemplateName));
      `log("Added:" @ Output.Quantity);
    }

    ProdInstance.Currently = eStrategyAssetProductionState_AwaitingInput;
    ProdInstance.NextTick = GetCurrentTime();
  }

  `log("Advancing Production " @ ProdInstance.ProductionID @ ProdInstance.Currently);

  return ProdInstance;
}


function StrategyAssetUpkeep AdvanceUpkeep(
  XComGameState GameState, StrategyAssetUpkeep UpkeepInstance
)
{
  local TDateTime NextTick;

  if (
    UpkeepInstance.Currently == eStrategyAssetUpkeepState_AwaitingCost ||
    UpkeepInstance.Currently == eStrategyAssetUpkeepState_InPenalty
  )
  {
    NextTick = GetCurrentTime();
    // consume resources for input (if possible)
    if (CanAffordAllArtifactCosts(UpkeepInstance.Cost))
    {
      ConsumeAllArtifactCosts(GameState, UpkeepInstance.Cost);
      UpkeepInstance.Currently = eStrategyAssetUpkeepState_Cycling;
      class'X2StrategyGameRulesetDataStructures'.static.AddHours(
        NextTick, UpkeepInstance.UpkeepFrequency
      );
    }
    else
    {
      // defer next tick for a day, will attempt upkeep again then
      UpkeepInstance.Currently = eStrategyAssetUpkeepState_InPenalty;
      class'X2StrategyGameRulesetDataStructures'.static.AddHours(NextTick, 24);
    }

    UpkeepInstance.NextTick = NextTick;
  } else {
    UpkeepInstance.Currently = eStrategyAssetUpkeepState_AwaitingCost;
    UpkeepInstance.NextTick = GetCurrentTime();
  }

  `log("Advancing Upkeep " @ UpkeepInstance.UpkeepID @ UpkeepInstance.Currently);

  return UpkeepInstance;
}


function AdvanceEconomy(XComGameState GameState) {
  local StrategyAssetStructure StructureInstance;
  local StrategyAssetProduction ProductionInstance;
  local StrategyAssetUpkeep UpkeepInstance;
  local TDateTime Now;
  local int ProductionIx, StructureIx, UpkeepIx;

  Now = GetCurrentTime();

  foreach Production(ProductionInstance, ProductionIx)
  {
    if (class'X2StrategyGameRulesetDataStructures'.static.LessThan(
      ProductionInstance.NextTick, Now
    ))
    {
      Production[ProductionIx] = AdvanceProduction(GameState, ProductionInstance);
    }
  }

  foreach Upkeep(UpkeepInstance, UpkeepIx)
  {
    if (class'X2StrategyGameRulesetDataStructures'.static.LessThan(
      UpkeepInstance.NextTick, Now
    ))
    {
      Upkeep[UpkeepIx] = AdvanceUpkeep(GameState, UpkeepInstance);
    }
  }

  foreach Structures(StructureInstance, StructureIx)
  {
    foreach StructureInstance.Production(ProductionInstance, ProductionIx)
    {
      if (class'X2StrategyGameRulesetDataStructures'.static.LessThan(
        ProductionInstance.NextTick, Now
      ))
      {
        StructureInstance.Production[ProductionIx] = AdvanceProduction(
          GameState, ProductionInstance
        );
      }
    }

    foreach StructureInstance.Upkeep(UpkeepInstance, UpkeepIx)
    {
      if (class'X2StrategyGameRulesetDataStructures'.static.LessThan(
        UpkeepInstance.NextTick, Now
      ))
      {
        StructureInstance.Upkeep[UpkeepIx] = AdvanceUpkeep(
          GameState, UpkeepInstance
        );
      }
    }

    Structures[StructureIx] = StructureInstance;
  }

  RefreshUpkeepPenalties();
  UpdateNextEconomyTick();
}


function RefreshUpkeepPenalties() {
  local StrategyAssetStructure StructureInstance;
  local StrategyAssetUpkeep UpkeepInstance;
  local StrategyAssetUpkeepPenalty
    PenaltyInstance, UpkeepPenaltyInstance, BlankUpkeepPenaltyInstance;
  local name Penalty;
  local bool bFound;
  local int StructureIx, UpkeepIx,
            PenaltyIx, FoundIx;

  foreach Upkeep(UpkeepInstance, UpkeepIx)
  {
    if (UpkeepInstance.Currently == eStrategyAssetUpkeepState_InPenalty)
    {
      `log("Checking UpkeepInstance Penalties for" @ UpkeepInstance.UpkeepID);
      foreach UpkeepInstance.Penalties(Penalty)
      {
        `log("Penalty:" @ Penalty);
        bFound = false;
        foreach UpkeepPenalties(PenaltyInstance, PenaltyIx)
        {
          if (
            PenaltyInstance.SourceUpkeepID == UpkeepInstance.UpkeepID &&
            PenaltyInstance.Penalty == Penalty
          )
          {
            bFound = true;

          }
        }

        `log("PenaltyFound:" @ bFound);
        if (!bFound) {
          UpkeepPenaltyInstance = BlankUpkeepPenaltyInstance;
          UpkeepPenaltyInstance.SourceUpkeepID = UpkeepInstance.UpkeepID;
          UpkeepPenaltyInstance.Penalty = Penalty;
          UpkeepPenaltyInstance.PenaltyStartTime = GetCurrentTime();
          UpkeepPenalties.AddItem(UpkeepPenaltyInstance);
          `log("Added Upkeep Penalty" @ UpkeepPenaltyInstance.Penalty);
        }
      }
    } else {
      `log("Clearing UpkeepInstance Penalties for" @ UpkeepInstance.UpkeepID);
      foreach UpkeepInstance.Penalties(Penalty)
      {
        `log("Penalty:" @ Penalty);
        bFound = false;
        FoundIx = -1;
        foreach UpkeepPenalties(PenaltyInstance, PenaltyIx)
        {
          if (
            PenaltyInstance.SourceUpkeepID == UpkeepInstance.UpkeepID &&
            PenaltyInstance.Penalty == Penalty
          )
          {
            bFound = true;
            FoundIx = PenaltyIx;
          }
        }

        `log("PenaltyFound:" @ bFound);
        if (bFound) {
          UpkeepPenalties.Remove(FoundIx, 1);
          `log("Removed Upkeep Penalty" @ Penalty);
        }
      }
    }
  }

  foreach Structures(StructureInstance, StructureIx)
  {
    foreach StructureInstance.Upkeep(UpkeepInstance, UpkeepIx)
    {
      if (UpkeepInstance.Currently == eStrategyAssetUpkeepState_InPenalty)
      {
        foreach UpkeepInstance.Penalties(Penalty)
        {
          bFound = false;
          foreach StructureInstance.UpkeepPenalties(PenaltyInstance, PenaltyIx)
          {
            if (
              PenaltyInstance.SourceUpkeepID == UpkeepInstance.UpkeepID &&
              PenaltyInstance.Penalty == Penalty
            )
            {
              bFound = true;

            }
          }

          if (!bFound) {
            UpkeepPenaltyInstance = BlankUpkeepPenaltyInstance;
            UpkeepPenaltyInstance.SourceUpkeepID = UpkeepInstance.UpkeepID;
            UpkeepPenaltyInstance.Penalty = Penalty;
            UpkeepPenaltyInstance.PenaltyStartTime = GetCurrentTime();
            StructureInstance.UpkeepPenalties.AddItem(UpkeepPenaltyInstance);
          }
        }
      } else {
        foreach UpkeepInstance.Penalties(Penalty)
        {
          bFound = false;
          FoundIx = -1;
          foreach StructureInstance.UpkeepPenalties(PenaltyInstance, PenaltyIx)
          {
            if (
              PenaltyInstance.SourceUpkeepID == UpkeepInstance.UpkeepID &&
              PenaltyInstance.Penalty == Penalty
            )
            {
              bFound = true;
              FoundIx = PenaltyIx;
            }
          }

          if (bFound) {
            StructureInstance.UpkeepPenalties.Remove(FoundIx, 1);
          }
        }
      }
    }

    Structures[StructureIx] = StructureInstance;
  }
}


function GlobalResistance_GameState_StrategyAsset CalculateProduction()
{
  local GlobalResistance_StrategyAssetTemplate Template;
  Template = GetMyTemplate();
  return Template.CalculateProductionDelegate(self);
}

function GlobalResistance_GameState_StrategyAsset CalculateUpkeep()
{
  local GlobalResistance_StrategyAssetTemplate Template;
  Template = GetMyTemplate();
  return Template.CalculateUpkeepDelegate(self);
}


function int CalculateInventoryCapacity()
{
  local GlobalResistance_StrategyAssetTemplate Template;
  Template = GetMyTemplate();
  return Template.CalculateInventoryCapacityDelegate(self);
}

function int CalculateUnitCapacity()
{
  local GlobalResistance_StrategyAssetTemplate Template;
  Template = GetMyTemplate();
  return Template.CalculateUnitCapacityDelegate(self);
}

function AddSquad(StrategyAssetSquad Squad)
{
  Squads.AddItem(Squad);
}


function Array<StrategyAssetSquad> GetInitialSquads() {
  return Squads;
}


function int GetStructureCount(name StructureType)
{
  local StrategyAssetStructure Structure;
  local int S_Count;
  foreach Structures(Structure)
  {
    if (Structure.Type == StructureType)
    {
      S_Count++;
    }
  }
  return S_Count;
}

function DestroyStructureOfType(name StructureType)
{
  //local StrategyAssetStructure Structure;
  local int ix;

  ix = Structures.Find('Type', StructureType);
  if (ix != -1)
  {
    Structures.Remove(ix, 1);
  }
}


function GlobalResistance_GameState_MissionSite SpawnMissionSite(name MissionSourceName, name MissionRewardName, optional name ExtraMissionRewardName)
{
  local XComGameStateHistory History;
  local XComGameState NewGameState;
  //local XComGameState_HeadquartersXCom XComHQ;
  local GlobalResistance_GameState_MissionSite MissionState;
  local X2MissionSourceTemplate MissionSource;
  local XComGameState_WorldRegion RegionState;
  local XComGameState_Reward RewardState;
  local array<XComGameState_Reward> MissionRewards;
  local X2RewardTemplate RewardTemplate;
  local X2StrategyElementTemplateManager StratMgr;
  
  History = `XCOMHISTORY;
  //XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
  RegionState = GetWorldRegion();
  StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
  MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate(MissionSourceName));
  RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate(MissionRewardName));

  NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("StrategySite: GenerateMission");
  RewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
  NewGameState.AddStateObject(RewardState);
  RewardState.GenerateReward(NewGameState, , RegionState.GetReference());
  MissionRewards.AddItem(RewardState);

  if(ExtraMissionRewardName != '')
  {
    RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate(ExtraMissionRewardName));

    if(RewardTemplate != none)
    {
      RewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
      NewGameState.AddStateObject(RewardState);
      RewardState.GenerateReward(NewGameState, , RegionState.GetReference());
      MissionRewards.AddItem(RewardState);
    }
  }

  MissionState = GlobalResistance_GameState_MissionSite(NewGameState.CreateStateObject(class'GlobalResistance_GameState_MissionSite'));
  NewGameState.AddStateObject(MissionState);
  MissionState.BuildMission(MissionSource, Get2DLocation(), RegionState.GetReference(), MissionRewards);
  MissionState.SiteGenerated = true;
  MissionState.RelatedStrategySiteRef = GetReference();

  if(NewGameState.GetNumGameStateObjects() > 0)
  {
    `XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
  }
  else
  {
    History.CleanupPendingGameState(NewGameState);
  }

  return MissionState;
}


function GlobalResistance_GameState_WorldRegion GetNearestWorldRegion()
{
  local X2WorldRegionTemplate RegionTemplate;
  local float ClosestDist, CheckDist;
  local XComGameState_WorldRegion RegionState, NearestRegion;

  closestDist = 100000000000000000000000;

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_WorldRegion', RegionState)
	{
    RegionTemplate = RegionState.GetMyTemplate();
    CheckDist = GetDistance(RegionTemplate.LandingLocation, Location);

    if (CheckDist < ClosestDist) {
      NearestRegion = RegionState;
      ClosestDist = CheckDist;
    }
  }

  return GlobalResistance_GameState_WorldRegion(NearestRegion);
}

function float GetDistance(Vector From, Vector To)
{
	local Vector DistVect;
	DistVect = From - To;
	return VSize(DistVect);
}




function array<GlobalResistance_GameState_StrategyAsset> GetShortestPathToAsset (
  GlobalResistance_GameState_StrategyAsset Asset
) {
  local XComGameStateHistory History;
  local GlobalResistance_GameState_Road ChildRoad;
  local array<GlobalResistance_GameState_StrategyAsset> FinalPath;
  local GlobalResistance_GameState_StrategyAsset
    NearestNodeToTarget, NearestNodeToSelf, TestNode;
  local array<AssetSearchNode> UnvisitedSet, VisitedSet;
  local AssetSearchNode BlankNode, TestSearchNode, ChildSearchNode, IterNode;
  local StateObjectReference StateRef, ChildRef;
  local float Distance, SelfDistance, TargetDistance, LowestDistance;
  local int Ix, IterIx;
  local bool bIsValid, bFoundTarget;

  History = `XCOMHISTORY;
  SelfDistance = -1;
  TargetDistance = -1;

  foreach History.IterateByClassType(class'GlobalResistance_GameState_StrategyAsset', TestNode)
  {
    Distance = GetDistance(Location, TestNode.Location);
    bIsValid = TestNode.ConnectedRoads.Length > 0;

    if (bIsValid)
    {
      TestSearchNode = BlankNode;
      TestSearchNode.ObjectID = TestNode.ObjectID;
      TestSearchNode.Node = TestNode;
      TestSearchNode.Distance = 100000000;
      UnvisitedSet.AddItem(TestSearchNode);
    }

    if (bIsValid && (Distance < SelfDistance || SelfDistance < 0))
    {
      SelfDistance = Distance;
      NearestNodeToSelf = TestNode;
    }

    Distance = GetDistance(Asset.Location, TestNode.Location);
    if (bIsValid && (Distance < TargetDistance || TargetDistance < 0))
    {
      TargetDistance = Distance;
      NearestNodeToTarget = TestNode;
    }
  }

  // test shortest distance direct
  // DirectDistance = GetDistance(Location, Asset.Location);

  Ix = UnvisitedSet.Find('ObjectID', NearestNodeToSelf.ObjectID);
  UnvisitedSet[Ix].Distance = 0;
  UnvisitedSet[Ix].OptimalSourceID = -1;

  while (UnvisitedSet.Length > 0 && !bFoundTarget)
  {
    LowestDistance = 10000000;
    foreach UnvisitedSet(IterNode, IterIx) {
      if (IterNode.Distance < LowestDistance) {
        LowestDistance = IterNode.Distance;
        Ix = IterIx;
      }
    }


    TestSearchNode = UnvisitedSet[Ix];
    UnvisitedSet.Remove(Ix, 1);
    VisitedSet.AddItem(TestSearchNode);

    if (TestSearchNode.ObjectID == NearestNodeToTarget.ObjectID)
    {
      bFoundTarget = true;
    }
    else
    {
      foreach TestSearchNode.Node.ConnectedRoads(StateRef)
      {
        ChildRoad = GlobalResistance_GameState_Road(
          History.GetGameStateForObjectID(StateRef.ObjectID)
        );

        if (ChildRoad.StateRefA.ObjectID != TestSearchNode.ObjectID) {
          ChildRef = ChildRoad.StateRefA;
        } else {
          ChildRef = ChildRoad.StateRefB;
        }

        Ix = UnvisitedSet.Find('ObjectID', ChildRef.ObjectID);
        ChildSearchNode = UnvisitedSet[Ix];
        if (Ix != INDEX_NONE)
        {
          Distance = GetDistance(
            TestSearchNode.Node.Location, ChildSearchNode.Node.Location
          );

          if (Distance < ChildSearchNode.Distance)
          {
            UnvisitedSet[Ix].Distance = Distance;
            UnvisitedSet[Ix].OptimalSourceID = TestSearchNode.ObjectID;
          }
        }
      }
    }
  }

  // test path against direct route
  while (TestSearchNode.OptimalSourceID != -1)
  {
    FinalPath.InsertItem(0, TestSearchNode.Node);
    Ix = VisitedSet.Find('ObjectID', TestSearchNode.OptimalSourceID);
    TestSearchNode = VisitedSet[Ix];
  }

  FinalPath.InsertItem(0, TestSearchNode.Node);

  return FinalPath;
}


function SetWaypointsToAsset (
  GlobalResistance_GameState_StrategyAsset Asset,
  name Speed,
  name DestinationJob = 'Wait',
  bool Track = false
) {
  local GlobalResistance_GameState_StrategyAsset PathNode;
  local Array<GlobalResistance_GameState_StrategyAsset> NodeChain;

  NodeChain = GetShortestPathToAsset(Asset);

  `log("Building Path:" @ NodeChain.Length);

  if (NodeChain.Length > 1) {
    foreach NodeChain(PathNode) {
      AddWaypoint(PathNode.Location, Speed);
    }
  }

  AddAssetWaypoint(Asset, Speed, DestinationJob, Track);
}


function SetToRandomLocationInRegion(XComGameState_WorldRegion WorldRegion)
{
  Location = WorldRegion.GetRandomLocationInRegion(,,self);
}


function AddAssetWaypoint (
  GlobalResistance_GameState_StrategyAsset Asset,
  name Speed,
  name DestinationJob,
  bool Track = false
) {
  local StrategyAssetWaypoint Waypoint;

  Waypoint.Location = Asset.Location;
  Waypoint.DestinationRef = Asset.GetReference();
  Waypoint.Speed = Speed;
  Waypoint.DestinationJob = DestinationJob;
  Waypoint.Tracking = Track;
  
  Waypoints.AddItem(Waypoint);
}

function AddWaypoint (
  Vector WaypointLoc,
  name Speed
) {
  local StrategyAssetWaypoint Waypoint;

  Waypoint.Location = WaypointLoc;
  Waypoint.Speed = Speed;
  Waypoint.Tracking = false;
  Waypoints.AddItem(Waypoint);
}


//---------------------------------------------------------------------------------------
//----------- XComGameState_GeoscapeEntity Implementation -------------------------------
//---------------------------------------------------------------------------------------


protected function bool CanInteract()
{
  return true;
}

function UpdateMovement(float fDeltaT)
{
  local Vector DirectionVector;
  local float DistanceRemaining, TravelDistance;
  local StrategyAssetWaypoint CurrentWaypoint;
  local XComGameState_WorldRegion RegionState;

  if (Location.X == -1.0 && Location.Y == -1.0) {
    RegionState = GetWorldRegion();
    Location = RegionState.GetRandomLocationInRegion(,,self);
  }

  // scale movement by time passage
  fDeltaT *= (`GAME.GetGeoscape().m_fTimeScale / `GAME.GetGeoscape().ONE_HOUR);
  TravelDistance = fDeltaT * 0.005;

  if (Waypoints.Length > 0)
  {
    CurrentWaypoint = Waypoints[0];
    DistanceRemaining = GetDistance(CurrentWaypoint.Location, Location);

    if (DistanceRemaining < TravelDistance)
    {
      // soak up remaining distance and transport to waypoint
      TravelDistance -= DistanceRemaining;
      Location.X = CurrentWaypoint.Location.X;
      Location.Y = CurrentWaypoint.Location.Y;

      if (CurrentWaypoint.DestinationRef.ObjectID != 0)
      {
        PerformWaypointJob(CurrentWaypoint);
      }
      Waypoints.RemoveItem(CurrentWaypoint);
    }
  }

  if (Waypoints.Length > 0)
  {
    CurrentWaypoint = Waypoints[0];

    DirectionVector = Normal(CurrentWaypoint.Location - Location);

    // use up remaining travel distance
    Location.X += DirectionVector.X * TravelDistance;
    Location.Y += DirectionVector.Y * TravelDistance;
  }
}

//---------------------------------------------------------------------------------------
function bool AboutToExpire()
{
  return false;
}

function class<UIStrategyMapItem> GetUIClass()
{
  return class'GlobalResistance_UIStrategyMapItem_StrategyAssetDebug';
}

function string GetUIWidgetFlashLibraryName()
{
  return string(class'UIPanel'.default.LibID);
}

function string GetUIPinImagePath()
{
  return "";
}

// The static mesh for this entities 3D UI
function StaticMesh GetStaticMesh()
{
  return StaticMesh(`CONTENT.RequestGameArchetype("UI_3D.Overwold_Final.GorillaOps"));
}

// Scale adjustment for the 3D UI static mesh
function vector GetMeshScale()
{
  local vector ScaleVector;

  ScaleVector.X = 0.8;
  ScaleVector.Y = 0.8;
  ScaleVector.Z = 0.8;

  return ScaleVector;
}

function Rotator GetMeshRotator()
{
  local Rotator MeshRotation;

  MeshRotation.Roll = 0;
  MeshRotation.Pitch = 0;
  MeshRotation.Yaw = 0;

  return MeshRotation;
}

function bool ShouldBeVisible()
{
  return true;
}

//function bool ShowFadedPin()
//{
//  return (bNotAtThreshold || bBuilding);
//}

function bool RequiresSquad()
{
  return true;
}


function GlobalResistance_GameState_RegionCommandAI GetRegionAI ()
{
  local XComGameStateHistory History;
  local GlobalResistance_GameState_RegionCommandAI AI;

  History = `XCOMHISTORY;

  foreach History.IterateByClassType(
    class'GlobalResistance_GameState_RegionCommandAI', AI
  )
  {
    if (AI.Region.ObjectID == Region.ObjectID) { return AI; }
  }

  return none;
}


function UpdateGameBoard()
{	
	local XComGameState NewGameState;
  local GlobalResistance_GameState_StrategyAsset NewAsset;

  if (class'X2StrategyGameRulesetDataStructures'.static.LessThan(NextEconomyTick, GetCurrentTime()))
  {
    `log("EconomyTick RUNS");
    NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("EconomyTickStrategyAsset");
    NewAsset = GlobalResistance_GameState_StrategyAsset(
      NewGameState.CreateStateObject(
        class'GlobalResistance_GameState_StrategyAsset', 
        ObjectID
      )
    );
    NewAsset.AdvanceEconomy(NewGameState);
    NewGameState.AddStateObject(NewAsset);
    `XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

    GetRegionAI().Update();
  }
}


function PerformWaypointJob(StrategyAssetWaypoint Waypoint)
{
  if (Waypoint.DestinationJob == 'DeliverAndDisband')
  {
    DeliverAndDisband(Waypoint);
  }
}

function DeliverAndDisband(StrategyAssetWaypoint Waypoint)
{
	local XComGameState NewGameState;
  local array<ArtifactCost> ArtifactTransfers;
  local ArtifactCost ArtifactTransfer;
  local bool DeliveryChange, DeliveryDidChange;
  local GlobalResistance_GameState_StrategyAsset DeliveryAsset;
  local GlobalResistance_GameState_RegionCommandAI NewAI;

  NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("EconomyTickStrategyAsset");
  DeliveryAsset = GlobalResistance_GameState_StrategyAsset(
    NewGameState.CreateStateObject(
      class'GlobalResistance_GameState_StrategyAsset', 
      Waypoint.DestinationRef.ObjectID
    )
  );
  NewAI = GlobalResistance_GameState_RegionCommandAI(
    NewGameState.CreateStateObject(
      class'GlobalResistance_GameState_RegionCommandAI', 
      DeliveryAsset.GetRegionAI().ObjectID
    )
  );

  ArtifactTransfers = GetInventoryAsArtifacts();
  foreach ArtifactTransfers(ArtifactTransfer)
  {
    ConsumeArtifactCost(NewGameState, ArtifactTransfer);
    DeliveryChange = DeliveryAsset.PutCostInInventory(NewGameState, ArtifactTransfer);
    if (DeliveryChange) {
      DeliveryDidChange = true;
    }
    NewAI.ReportCompletedDispatch(
      NewGameState, DeliveryAsset, self, ArtifactTransfer
    );
  }

  if (DeliveryDidChange)
  {
    NewGameState.AddStateObject(DeliveryAsset);
  }
  else
  {
    NewGameState.PurgeGameStateForObjectID(DeliveryAsset.ObjectID);
  }
  NewGameState.AddStateObject(NewAI);
  NewGameState.RemoveStateObject(ObjectID);
  RemoveMapPin();
  `XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

simulated function name GetMyTemplateName()
{
  return m_TemplateName;
}

//---------------------------------------------------------------------------------------
static function X2StrategyElementTemplateManager GetMyTemplateManager()
{
  return class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
}

simulated function GlobalResistance_StrategyAssetTemplate GetMyTemplate()
{
  if (m_AssetTemplate == none)
  {
    m_AssetTemplate = GlobalResistance_StrategyAssetTemplate(GetMyTemplateManager().FindStrategyElementTemplate(m_TemplateName));
  }
  return m_AssetTemplate;
}

protected function bool DisplaySelectionPrompt()
{
  local GlobalResistance_UIStrategyAsset kScreen;
  local class<GlobalResistance_UIStrategyAsset> kScreenClass;

  kScreenClass = GetMyTemplate().StrategyUIClass;

  if(!`HQPRES.ScreenStack.GetCurrentScreen().IsA('GlobalResistance_UIStrategyAsset'))
  {
    `log("Loading" @ kScreenClass);
    kScreen = `HQPRES.Spawn(kScreenClass, `HQPRES);
    kScreen.bInstantInterp = false;
    kScreen.StrategyAsset = self;
    `HQPRES.ScreenStack.Push(kScreen);
  }

  if( `GAME.GetGeoscape().IsScanning() )
    `HQPRES.StrategyMap2D.ToggleScan();

  return true;
}

function RemoveEntity(XComGameState NewGameState)
{
  `assert(false);
}

function string GetUIButtonIcon()
{
  return "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_Advent";
}
