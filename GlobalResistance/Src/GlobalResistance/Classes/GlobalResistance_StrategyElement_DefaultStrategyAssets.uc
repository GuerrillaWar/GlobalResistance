class GlobalResistance_StrategyElement_DefaultStrategyAssets extends X2StrategyElement config(GR_StrategyAssets);

var name GeneClinicName;
var name RecruitmentCentreName;
var name SupplyCentreName;

var const config array<StrategyAssetTemplateDefinition> arrTemplateDefinitions;
var const config array<StrategyAssetStructureDefinition> arrStructureDefinitions;

static function array<X2DataTemplate> CreateTemplates()
{
  local array<X2DataTemplate> AssetTemplates;

  AssetTemplates.AddItem(CreateCityControlZone());
  AssetTemplates.AddItem(CreateSlumCity());
  AssetTemplates.AddItem(CreateResistanceCamp());
  AssetTemplates.AddItem(CreateAdventConvoy());
  AssetTemplates.AddItem(CreateGuardPost());
  // AssetTemplates.AddItem(CreateAdventTransportBase());
  AssetTemplates.AddItem(CreateAdventBlacksite());
  // AssetTemplates.AddItem(CreateAlienPsiGate());
  AssetTemplates.AddItem(CreateAvatarFacility());
  // AssetTemplates.AddItem(CreateAdventForge());
  
  return AssetTemplates;
}


static function StrategyAssetStructureDefinition GetStructureDefinition(
  Name DefName
) {
  local StrategyAssetStructureDefinition StructureDef;
  
  `log("Structures to Search:" @ default.arrStructureDefinitions.length);
  foreach default.arrStructureDefinitions(StructureDef)
  {
    `log("StructureSearch" @ DefName @ "-" @ StructureDef.ID);
    if (StructureDef.ID == DefName) {
      return StructureDef;
    }
  }
}


static function ApplyTemplateDefinition(
  Name DefName,
  GlobalResistance_StrategyAssetTemplate Template
) {
  local StrategyAssetTemplateDefinition TemplateDef;
  
  foreach default.arrTemplateDefinitions(TemplateDef)
  {
    if (TemplateDef.ID == DefName)
    {
      Template.Production = TemplateDef.Production;
      Template.Upkeep = TemplateDef.Upkeep;
      Template.UnitCapacity = TemplateDef.UnitCapacity;
      Template.InventoryCapacity = TemplateDef.InventoryCapacity;
      Template.MilitaryRequirements = TemplateDef.MilitaryRequirements;
    }
  }
}


static function ArtifactCost GenerateArtifactCost(Name ItemTemplateName, int Quantity)
{
  local ArtifactCost Cost;
  Cost.ItemTemplateName = ItemTemplateName;
  Cost.Quantity = Quantity;
  return Cost;
}


static function X2DataTemplate CreateCityControlZone()
{
  local GlobalResistance_StrategyAssetTemplate Template;

  `CREATE_X2TEMPLATE(class'GlobalResistance_StrategyAssetTemplate', Template, 'StrategyAsset_CityControlZone');

  Template.AssetCategory = eStrategyAssetCategory_Static;
  Template.DefaultTeam = eTeam_Alien;

  ApplyTemplateDefinition('CityControlZone', Template);
  Template.HasCoreStructure = false;
  Template.GameStateClass = class'GlobalResistance_GameState_CityStrategyAsset';
  Template.StrategyUIClass = class'GlobalResistance_UIStrategyAsset_CityControlZone';
  Template.PlotTypes.AddItem('CityCenter');
  Template.PlotTypes.AddItem('SmallTown');

  Template.AllowedStructures.AddItem(GetStructureDefinition('GeneClinic'));
  Template.AllowedStructures.AddItem(GetStructureDefinition('SupplyCentre'));

  Template.CalculateUnitCapacityDelegate = TypicalAsset_CalculateUnitCapacity;
  Template.CalculateInventoryCapacityDelegate = TypicalAsset_CalculateInventoryCapacity;
  Template.CalculateProductionDelegate = TypicalAsset_CalculateProduction;
  Template.CalculateUpkeepDelegate = TypicalAsset_CalculateUpkeep;

  return Template;
}


static function X2DataTemplate CreateSlumCity()
{
  local GlobalResistance_StrategyAssetTemplate Template;

  `CREATE_X2TEMPLATE(class'GlobalResistance_StrategyAssetTemplate', Template, 'StrategyAsset_SlumCity');

  Template.AssetCategory = eStrategyAssetCategory_Static;
  Template.DefaultTeam = eTeam_Alien;

  ApplyTemplateDefinition('SlumCity', Template);
  Template.HasCoreStructure = false;
  Template.GameStateClass = class'GlobalResistance_GameState_CityStrategyAsset';
  Template.StrategyUIClass = class'GlobalResistance_UIStrategyAsset_CityControlZone';
  Template.PlotTypes.AddItem('Slums');

  Template.AllowedStructures.AddItem(GetStructureDefinition('SupplyCentre'));
  Template.AllowedStructures.AddItem(GetStructureDefinition('Farm'));

  Template.CalculateUnitCapacityDelegate = TypicalAsset_CalculateUnitCapacity;
  Template.CalculateInventoryCapacityDelegate = TypicalAsset_CalculateInventoryCapacity;
  Template.CalculateProductionDelegate = TypicalAsset_CalculateProduction;
  Template.CalculateUpkeepDelegate = TypicalAsset_CalculateUpkeep;

  return Template;
}


static function X2DataTemplate CreateGuardPost()
{
  local GlobalResistance_StrategyAssetTemplate Template;

  `CREATE_X2TEMPLATE(class'GlobalResistance_StrategyAssetTemplate', Template, 'StrategyAsset_GuardPost');

  Template.AssetCategory = eStrategyAssetCategory_Static;
  Template.DefaultTeam = eTeam_Alien;
  Template.InventoryCapacity = 200;
  Template.UnitCapacity = 15;
  Template.HasCoreStructure = false;
  Template.GameStateClass = class'GlobalResistance_GameState_GuardPostAsset';
  Template.StrategyUIClass = class'GlobalResistance_UIStrategyAsset_GuardPost';
  Template.PlotTypes.AddItem('Wilderness');

  Template.CalculateUnitCapacityDelegate = TypicalAsset_CalculateUnitCapacity;
  Template.CalculateInventoryCapacityDelegate = TypicalAsset_CalculateInventoryCapacity;
  Template.CalculateProductionDelegate = TypicalAsset_CalculateProduction;
  Template.CalculateUpkeepDelegate = TypicalAsset_CalculateUpkeep;

  return Template;
}


static function X2DataTemplate CreateAvatarFacility()
{
  local GlobalResistance_StrategyAssetTemplate Template;

  `CREATE_X2TEMPLATE(class'GlobalResistance_StrategyAssetTemplate', Template, 'StrategyAsset_AvatarFacility');

  Template.AssetCategory = eStrategyAssetCategory_Static;
  Template.DefaultTeam = eTeam_Alien;
  Template.InventoryCapacity = 1000;
  Template.UnitCapacity = 40;
  Template.HasCoreStructure = true;
  ApplyTemplateDefinition('AvatarFacility', Template);
  Template.CoreStructure = GetStructureDefinition('AvatarFacility');
  Template.AllowedStructures.AddItem(GetStructureDefinition('AvatarFacility'));
  Template.GameStateClass = class'GlobalResistance_GameState_AvatarFacilityStrategyAsset';
  Template.StrategyUIClass = class'GlobalResistance_UIStrategyAsset_AvatarFacility';
  Template.PlotTypes.AddItem('Wilderness');

  Template.CalculateUnitCapacityDelegate = TypicalAsset_CalculateUnitCapacity;
  Template.CalculateInventoryCapacityDelegate = TypicalAsset_CalculateInventoryCapacity;
  Template.CalculateProductionDelegate = TypicalAsset_CalculateProduction;
  Template.CalculateUpkeepDelegate = TypicalAsset_CalculateUpkeep;

  return Template;
}


static function X2DataTemplate CreateAdventBlacksite()
{
  local GlobalResistance_StrategyAssetTemplate Template;

  `CREATE_X2TEMPLATE(class'GlobalResistance_StrategyAssetTemplate', Template, 'StrategyAsset_AdventBlacksite');

  Template.AssetCategory = eStrategyAssetCategory_Static;
  Template.DefaultTeam = eTeam_Alien;
  ApplyTemplateDefinition('Blacksite', Template);
  Template.HasCoreStructure = true;
  Template.CoreStructure = GetStructureDefinition('Blacksite');
  Template.AllowedStructures.AddItem(GetStructureDefinition('Blacksite'));

  Template.GameStateClass = class'GlobalResistance_GameState_AdventBlacksiteStrategyAsset';
  Template.StrategyUIClass = class'GlobalResistance_UIStrategyAsset_AdventBlacksite';
  Template.PlotTypes.AddItem('Wilderness');


  Template.CalculateUnitCapacityDelegate = TypicalAsset_CalculateUnitCapacity;
  Template.CalculateInventoryCapacityDelegate = TypicalAsset_CalculateInventoryCapacity;
  Template.CalculateProductionDelegate = TypicalAsset_CalculateProduction;
  Template.CalculateUpkeepDelegate = TypicalAsset_CalculateUpkeep;

  return Template;
}


static function X2DataTemplate CreateResistanceCamp()
{
  local GlobalResistance_StrategyAssetTemplate Template;

  `CREATE_X2TEMPLATE(class'GlobalResistance_StrategyAssetTemplate', Template, 'StrategyAsset_ResistanceCamp');

  Template.AssetCategory = eStrategyAssetCategory_Buildable;
  Template.DefaultTeam = eTeam_XCom;
  Template.InventoryCapacity = 1000;
  Template.UnitCapacity = 100;
  Template.HasCoreStructure = false;
  Template.GameStateClass = class'GlobalResistance_GameState_ResistanceCamp';
  Template.StrategyUIClass = class'GlobalResistance_UIStrategyAsset_ResistanceCamp';
  Template.PlotTypes.AddItem('Shanty');

  Template.CalculateUnitCapacityDelegate = TypicalAsset_CalculateUnitCapacity;
  Template.CalculateInventoryCapacityDelegate = TypicalAsset_CalculateInventoryCapacity;
  Template.CalculateProductionDelegate = TypicalAsset_CalculateProduction;
  Template.CalculateUpkeepDelegate = TypicalAsset_CalculateUpkeep;

  return Template;
}


static function X2DataTemplate CreateAdventConvoy()
{
  local GlobalResistance_StrategyAssetTemplate Template;
  local StrategyAssetSpeed Speed, BlankSpeed;

  `CREATE_X2TEMPLATE(class'GlobalResistance_StrategyAssetTemplate', Template, 'StrategyAsset_AdventConvoy');

  Template.AssetCategory = eStrategyAssetCategory_Mobile;
  Template.DefaultTeam = eTeam_Alien;
  Template.InventoryCapacity = 200;
  Template.UnitCapacity = 15;
  Template.HasCoreStructure = false;
  Template.GameStateClass = class'GlobalResistance_GameState_StrategyAsset';
  Template.StrategyUIClass = class'GlobalResistance_UIStrategyAsset_ResistanceCamp';

  Speed = BlankSpeed;
  Speed.ID = 'Standard';
  Speed.Velocity = 0.1;

  Template.Speeds.AddItem(Speed);

  Template.CalculateUnitCapacityDelegate = TypicalAsset_CalculateUnitCapacity;
  Template.CalculateInventoryCapacityDelegate = TypicalAsset_CalculateInventoryCapacity;
  Template.CalculateProductionDelegate = TypicalAsset_CalculateProduction;
  Template.CalculateUpkeepDelegate = TypicalAsset_CalculateUpkeep;

  return Template;
}


// DELEGATE
static function int TypicalAsset_CalculateInventoryCapacity(
  GlobalResistance_GameState_StrategyAsset Asset
)
{
  local GlobalResistance_StrategyAssetTemplate Template;
  local StrategyAssetStructure Structure;
  local StrategyAssetStructureDefinition StructureDef;
  local int Capacity;

  Template = Asset.GetMyTemplate();
  Capacity = 0;
  Capacity += Template.InventoryCapacity;

  foreach Asset.Structures(Structure)
  {
    StructureDef = GetStructureDefinition(Structure.Type);
    Capacity += StructureDef.InventoryCapacity;
  }

  return Capacity;
}


static function int TypicalAsset_CalculateUnitCapacity(
  GlobalResistance_GameState_StrategyAsset Asset
)
{
  local GlobalResistance_StrategyAssetTemplate Template;
  local StrategyAssetStructure Structure;
  local StrategyAssetStructureDefinition StructureDef;
  local int Capacity;

  Template = Asset.GetMyTemplate();
  Capacity = 0;
  Capacity += Template.UnitCapacity;

  foreach Asset.Structures(Structure)
  {
    StructureDef = GetStructureDefinition(Structure.Type);
    Capacity += StructureDef.UnitCapacity;
  }

  return Capacity;
}


static function GlobalResistance_GameState_StrategyAsset TypicalAsset_CalculateProduction(
  GlobalResistance_GameState_StrategyAsset Asset
)
{
  local GlobalResistance_StrategyAssetTemplate Template;
  local StrategyAssetStructure Structure;
  local StrategyAssetProduction Production, BlankProduction;
  local StrategyAssetStructureDefinition StructureDef;
  local StrategyAssetProductionDefinition ProductionDef;
  local int ProdIx, StructureIx;
  local bool bFound;

  Template = Asset.GetMyTemplate();

  foreach Template.Production(ProductionDef)
  {
    bFound = false;
    foreach Asset.Production(Production, ProdIx)
    {
      if (Production.ProductionID == ProductionDef.ProductionID)
      {
        bFound = true;
        Production.Inputs = ProductionDef.Inputs;
        Production.Outputs = ProductionDef.Outputs;
        Production.ProductionTime = ProductionDef.ProductionTime;
        Asset.Production[ProdIx] = Production;
      }
    }

    if (!bFound) {
      `log("Adding Production Type:" @ ProductionDef.ProductionID);
      Production = BlankProduction;
      Production.Inputs = ProductionDef.Inputs;
      Production.Outputs = ProductionDef.Outputs;
      Production.ProductionTime = ProductionDef.ProductionTime;
      Production.ProductionID = ProductionDef.ProductionID;
      Production.NextTick = Asset.GetCurrentTime();
      Asset.Production.AddItem(Production);
    }
  }

  foreach Asset.Structures(Structure, StructureIx)
  {
    StructureDef = GetStructureDefinition(Structure.Type);

    foreach StructureDef.Production(ProductionDef)
    {
      bFound = false;
      foreach Structure.Production(Production, ProdIx)
      {
        if (Production.ProductionID == ProductionDef.ProductionID)
        {
          bFound = true;
          Production.Inputs = ProductionDef.Inputs;
          Production.Outputs = ProductionDef.Outputs;
          Production.ProductionTime = ProductionDef.ProductionTime;
          Asset.Production[ProdIx] = Production;
        }
      }

      if (!bFound) {
        `log("Adding Production Type:" @ ProductionDef.ProductionID);
        Production = BlankProduction;
        Production.Inputs = ProductionDef.Inputs;
        Production.Outputs = ProductionDef.Outputs;
        Production.ProductionTime = ProductionDef.ProductionTime;
        Production.ProductionID = ProductionDef.ProductionID;
        Production.NextTick = Asset.GetCurrentTime();
        Structure.Production.AddItem(Production);
      }
    }

    Asset.Structures[StructureIx] = Structure;
  }

  return Asset;
}


static function GlobalResistance_GameState_StrategyAsset TypicalAsset_CalculateUpkeep(
  GlobalResistance_GameState_StrategyAsset Asset
)
{
  local GlobalResistance_StrategyAssetTemplate Template;
  local StrategyAssetStructure Structure;
  local StrategyAssetUpkeep Upkeep, BlankUpkeep;
  local StrategyAssetStructureDefinition StructureDef;
  local StrategyAssetUpkeepDefinition UpkeepDef;
  local int UpkeepIx, StructureIx;
  local bool bFound;

  Template = Asset.GetMyTemplate();

  foreach Template.Upkeep(UpkeepDef)
  {
    bFound = false;
    foreach Asset.Upkeep(Upkeep, UpkeepIx)
    {
      if (Upkeep.UpkeepID == UpkeepDef.UpkeepID)
      {
        bFound = true;
        Upkeep.Cost = UpkeepDef.Cost;
        Upkeep.Penalties = UpkeepDef.Penalties;
        Upkeep.UpkeepFrequency = UpkeepDef.UpkeepFrequency;
        Asset.Upkeep[UpkeepIx] = Upkeep;
      }
    }

    if (!bFound) {
      `log("Adding Upkeep Type:" @ UpkeepDef.UpkeepID);
      Upkeep = BlankUpkeep;
      Upkeep.Cost = UpkeepDef.Cost;
      Upkeep.UpkeepFrequency = UpkeepDef.UpkeepFrequency;
      Upkeep.Penalties = UpkeepDef.Penalties;
      Upkeep.UpkeepID = UpkeepDef.UpkeepID;
      Upkeep.NextTick = Asset.GetCurrentTime();
      Asset.Upkeep.AddItem(Upkeep);
    }
  }

  foreach Asset.Structures(Structure, StructureIx)
  {
    StructureDef = GetStructureDefinition(Structure.Type);

    foreach StructureDef.Upkeep(UpkeepDef)
    {
      bFound = false;
      foreach Structure.Upkeep(Upkeep, UpkeepIx)
      {
        if (Upkeep.UpkeepID == UpkeepDef.UpkeepID)
        {
          bFound = true;
          Upkeep.Cost = UpkeepDef.Cost;
          Upkeep.Penalties = UpkeepDef.Penalties;
          Upkeep.UpkeepFrequency = UpkeepDef.UpkeepFrequency;
          Asset.Upkeep[UpkeepIx] = Upkeep;
        }
      }

      if (!bFound) {
        `log("Adding Upkeep Type:" @ UpkeepDef.UpkeepID);
        Upkeep = BlankUpkeep;
        Upkeep.Cost = UpkeepDef.Cost;
        Upkeep.UpkeepFrequency = UpkeepDef.UpkeepFrequency;
        Upkeep.Penalties = UpkeepDef.Penalties;
        Upkeep.UpkeepID = UpkeepDef.UpkeepID;
        Upkeep.NextTick = Asset.GetCurrentTime();
        Structure.Upkeep.AddItem(Upkeep);
      }
    }

    Asset.Structures[StructureIx] = Structure;
  }

  return Asset;
}




defaultproperties
{
  GeneClinicName="GeneClinic"
  HospitalName="Hospital"
  FarmName="Farm"
  MunitionsFactoryName="MunitionsFactory"
  RecruitmentCentreName="RecruitmentCentre"
  SupplyCentreName="SupplyCentre"
}
