class GlobalResistance_UIStrategyMapItem_StrategyAssetDebug extends UIStrategyMapItem;

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
  local StrategyAssetUpkeepPenalty PenaltyInstance;
  local StateObjectReference ItemRef;
  local XComGameState_Item Item;
	local XComGameStateHistory History;
  local string AssetDesc;
  local array<EconomicNeed> arrNeeds;
  local EconomicNeed Need;
  local array<EconomicAvailability> arrAvailabilities;
  local EconomicAvailability Availability;

	if( !bIsInited ) return; 

	History = `XCOMHISTORY;
	super.UpdateFromGeoscapeEntity(GeoscapeEntity);
  Asset = GetAsset();
  AssetDesc = "";

  if (
    class'GlobalResistance_DebugManager'.static.GetSingleton().bStrategyShowEconomicStates
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
    class'GlobalResistance_DebugManager'.static.GetSingleton().bStrategyShowInventory
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
    class'GlobalResistance_DebugManager'.static.GetSingleton().bStrategyShowEconomicSignals
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
