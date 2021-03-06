class GlobalResistance_UIStrategyMapItem_StrategyAssetDebug extends UIStrategyMapItem;

struct DebugSquadCount
{
  var name SquadType;
  var int Count;
};

var UIText InfoText;

simulated function UIStrategyMapItem InitMapItem(out XComGameState_GeoscapeEntity Entity)
{
	// Spawn the children BEFORE the super.Init because inside that super, it will trigger UpdateFlyoverText and other functions
	// which may assume these children already exist. 
		
	super.InitMapItem(Entity);

	InfoText = Spawn(class'UIText', self);
  InfoText.InitText(
    'TextInfo',
    "Test Text\nTest Text", false
  );
  InfoText.SetText("Test Text\nTest Text");

	return self;
}

function UpdateFromGeoscapeEntity(const out XComGameState_GeoscapeEntity GeoscapeEntity)
{
  local GlobalResistance_GameState_StrategyAsset Asset;
  local StrategyAssetStructure StructureInstance;
  local StrategyAssetProduction ProductionInstance;
  local StrategyAssetUpkeep UpkeepInstance;

  local array<MilitaryStatus> MilitaryStatusList;
  local MilitaryStatus MilitaryStatus;
  local StrategyAssetSquad Squad;
  local array<DebugSquadCount> SquadCounts;
  local int SquadCountIx;

  local DebugSquadCount SquadCount;
  local StrategyAssetUpkeepPenalty PenaltyInstance;
  local StateObjectReference ItemRef;
  local XComGameState_Item Item;
	local XComGameStateHistory History;
  local string AssetDesc;
  local array<EconomicNeed> arrNeeds;
  local EconomicNeed Need;
  local GenericUnitCount UnitCount;
  local array<EconomicAvailability> arrAvailabilities;
  local EconomicAvailability Availability;

	if( !bIsInited ) return; 

	History = `XCOMHISTORY;
	super.UpdateFromGeoscapeEntity(GeoscapeEntity);
  Asset = GetAsset();
  AssetDesc = "";

  if (
    class'GlobalResistance_DebugManager'.static.GetSingleton().eStrategyAssetDebugState == eStrategyDebugStatus_EconomicStates
  )
  {
    foreach Asset.Upkeep(UpkeepInstance)
    {
      AssetDesc = AssetDesc $
        UpkeepInstance.UpkeepID @ UpkeepInstance.Currently $ "\n";
    }

    foreach Asset.UpkeepPenalties(PenaltyInstance)
    {
      AssetDesc = AssetDesc $
        PenaltyInstance.Penalty @ PenaltyInstance.SourceUpkeepID $ "\n";
    }

    foreach Asset.Production(ProductionInstance)
    {
      AssetDesc = AssetDesc $
        ProductionInstance.ProductionID @ ProductionInstance.Currently $ "\n";
    }

    foreach Asset.Structures(StructureInstance)
    {
      AssetDesc = AssetDesc $ "Structure:" @ StructureInstance.Type $ "\n";

      foreach StructureInstance.Upkeep(UpkeepInstance)
      {
        AssetDesc = AssetDesc $ "- " $
          UpkeepInstance.UpkeepID @ UpkeepInstance.Currently $ "\n";
      }

      foreach StructureInstance.UpkeepPenalties(PenaltyInstance)
      {
        AssetDesc = AssetDesc $ "- " $
          PenaltyInstance.Penalty @ PenaltyInstance.SourceUpkeepID $ "\n";
      }

      foreach StructureInstance.Production(ProductionInstance)
      {
        AssetDesc = AssetDesc $ "- " $
          ProductionInstance.ProductionID @ ProductionInstance.Currently $ "\n";
      }
    }
  }
  else if (
    class'GlobalResistance_DebugManager'.static.GetSingleton().eStrategyAssetDebugState == eStrategyDebugStatus_Inventory
  )
  {
    foreach Asset.Inventory(ItemRef)
    {
      Item = XComGameState_Item(History.GetGameStateForObjectID(ItemRef.ObjectId));
      AssetDesc = AssetDesc $
        Item.GetMyTemplateName() @ "-" @ Item.Quantity $ "\n";
    }
  }
  else if (
    class'GlobalResistance_DebugManager'.static.GetSingleton().eStrategyAssetDebugState == eStrategyDebugStatus_MilitaryStates
  )
  {
    foreach Asset.Reserves(UnitCount)
    {
      AssetDesc = AssetDesc $
        UnitCount.CharacterTemplate @ "-" @ UnitCount.Count $ "\n";
    }
  }
  else if (
    class'GlobalResistance_DebugManager'.static.GetSingleton().eStrategyAssetDebugState == eStrategyDebugStatus_EconomicSignals
  )
  {
    arrNeeds = Asset.GetRegionAI().GetEconomicNeedsForAssetID(Asset.ObjectID);
    arrAvailabilities = Asset.GetRegionAI().GetEconomicAvailabilitiesForAssetID(Asset.ObjectID);

    if (arrNeeds.Length > 0)
    {
      AssetDesc = AssetDesc $ "NEEDS:\n";
      foreach arrNeeds(Need)
      {
        AssetDesc = AssetDesc $ Need.ItemTemplateName @ Need.QuantityDispatched $ "/" $ Need.Quantity $ "\n";
      }
    }

    if (arrAvailabilities.Length > 0)
    {
      AssetDesc = AssetDesc $ "AVAILABLE:\n";
      foreach arrAvailabilities(Availability)
      {
        AssetDesc = AssetDesc $ Availability.ItemTemplateName @ Availability.Quantity $ "\n";
      }
    }
  }
  else if (
    class'GlobalResistance_DebugManager'.static.GetSingleton().eStrategyAssetDebugState == eStrategyDebugStatus_SquadDeployments
  )
  {
    foreach Asset.Squads(Squad)
    {
      SquadCountIx = SquadCounts.Find('SquadType', Squad.SquadType);
      if (SquadCountIx == INDEX_NONE)
      {
        SquadCount.SquadType = Squad.SquadType;
        SquadCount.Count = 1;
        SquadCounts.AddItem(SquadCount);
      }
      else
      {
        SquadCounts[SquadCountIx].Count += 1;
      }
    }

    MilitaryStatusList = Asset.GetRegionAI().GetMilitaryStatusOfAsset(Asset);
    foreach MilitaryStatusList(MilitaryStatus)
    {
      AssetDesc = AssetDesc $ MilitaryStatus.Role @ MilitaryStatus.Quantity $ "/" $ MilitaryStatus.QuantityNeeded $ "\n";
    }

    foreach SquadCounts(SquadCount)
    {
      AssetDesc = AssetDesc $ SquadCount.SquadType @ "x" @ SquadCount.Count $ "\n";
    }
  }

  InfoText.SetText(AssetDesc);
}

simulated function GlobalResistance_GameState_StrategyAsset GetAsset()
{
	return GlobalResistance_GameState_StrategyAsset(
    `XCOMHISTORY.GetGameStateForObjectID(GeoscapeEntityRef.ObjectID)
  );
}

defaultproperties
{
	bProcessesMouseEvents = false;
	bNeedsUpdate = true;
  bFadeWhenZoomedOut = true;
}
