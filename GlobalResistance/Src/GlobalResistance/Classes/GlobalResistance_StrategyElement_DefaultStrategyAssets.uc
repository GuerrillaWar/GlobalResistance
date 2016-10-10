class GlobalResistance_StrategyElement_DefaultStrategyAssets extends X2StrategyElement config(GlobalResistance);

var name GeneClinicName;
var name RecruitmentCentreName;
var name SupplyCentreName;

static function array<X2DataTemplate> CreateTemplates()
{
  local array<X2DataTemplate> AssetTemplates;

  AssetTemplates.AddItem(CreateCityControlZone());
  AssetTemplates.AddItem(CreateSlumCity());
  AssetTemplates.AddItem(CreateResistanceCamp());
  AssetTemplates.AddItem(CreateAdventConvoy());
  
  return AssetTemplates;
}

static function AddSupplyCentreStructureDef(GlobalResistance_StrategyAssetTemplate Template)
{
  local StrategyAssetStructureDefinition StructureDef;
  local StrategyAssetProductionDefinition ProductionDef;
  local ArtifactCost Resources;

  StructureDef.ID = default.SupplyCentreName;

  Resources.ItemTemplateName = 'Supplies';
  Resources.Quantity = 400;
  StructureDef.BuildCost.AddItem(Resources);

  StructureDef.BuildHours = 24 * 7;
  
  ProductionDef.ItemTemplateName = 'Supplies';
  ProductionDef.CycleQuantity = 100;
  StructureDef.BaseProductionCapability.AddItem(ProductionDef);

  Template.AllowedStructures.AddItem(StructureDef);
}

static function AddGeneClinicStructureDef(GlobalResistance_StrategyAssetTemplate Template)
{
  local StrategyAssetStructureDefinition StructureDef;
  local StrategyAssetProductionDefinition ProductionDef;
  local ArtifactCost Resources;

  StructureDef.ID = default.GeneClinicName;

  Resources.ItemTemplateName = 'Supplies';
  Resources.Quantity = 400;
  StructureDef.BuildCost.AddItem(Resources);

  StructureDef.BuildHours = 24 * 7;
  
  ProductionDef.ItemTemplateName = 'Supplies';
  ProductionDef.CycleQuantity = 10;
  StructureDef.BaseProductionCapability.AddItem(ProductionDef);

  Template.AllowedStructures.AddItem(StructureDef);
}

static function X2DataTemplate CreateCityControlZone()
{
  local GlobalResistance_StrategyAssetTemplate Template;

  `CREATE_X2TEMPLATE(class'GlobalResistance_StrategyAssetTemplate', Template, 'StrategyAsset_CityControlZone');

  Template.AssetCategory = eStrategyAssetCategory_Static;
  Template.DefaultTeam = eTeam_Alien;
  Template.BaseInventoryCapacity = 2000;
  Template.BaseUnitCapacity = 1000;
  Template.HasCoreStructure = false;
  Template.GameStateClass = class'GlobalResistance_GameState_CityStrategyAsset';
  Template.StrategyUIClass = class'GlobalResistance_UIStrategyAsset_CityControlZone';
  Template.PlotTypes.AddItem('CityCenter');
  Template.PlotTypes.AddItem('SmallTown');

  AddSupplyCentreStructureDef(Template);
  AddGeneClinicStructureDef(Template);

  return Template;
}

static function X2DataTemplate CreateSlumCity()
{
  local GlobalResistance_StrategyAssetTemplate Template;

  `CREATE_X2TEMPLATE(class'GlobalResistance_StrategyAssetTemplate', Template, 'StrategyAsset_SlumCity');

  Template.AssetCategory = eStrategyAssetCategory_Static;
  Template.DefaultTeam = eTeam_Alien;
  Template.BaseInventoryCapacity = 1000;
  Template.BaseUnitCapacity = 400;
  Template.HasCoreStructure = false;
  Template.GameStateClass = class'GlobalResistance_GameState_CityStrategyAsset';
  Template.StrategyUIClass = class'GlobalResistance_UIStrategyAsset_CityControlZone';
  Template.PlotTypes.AddItem('Slums');

  AddSupplyCentreStructureDef(Template);

  return Template;
}


static function X2DataTemplate CreateResistanceCamp()
{
  local GlobalResistance_StrategyAssetTemplate Template;

  `CREATE_X2TEMPLATE(class'GlobalResistance_StrategyAssetTemplate', Template, 'StrategyAsset_ResistanceCamp');

  Template.AssetCategory = eStrategyAssetCategory_Buildable;
  Template.DefaultTeam = eTeam_XCom;
  Template.BaseInventoryCapacity = 1000;
  Template.BaseUnitCapacity = 100;
  Template.HasCoreStructure = false;
  Template.GameStateClass = class'GlobalResistance_GameState_StrategyAsset';
  Template.StrategyUIClass = class'GlobalResistance_UIStrategyAsset_ResistanceCamp';
  Template.PlotTypes.AddItem('Shanty');

  return Template;
}


static function X2DataTemplate CreateAdventConvoy()
{
  local GlobalResistance_StrategyAssetTemplate Template;
  local StrategyAssetSpeed Speed, BlankSpeed;

  `CREATE_X2TEMPLATE(class'GlobalResistance_StrategyAssetTemplate', Template, 'StrategyAsset_AdventConvoy');

  Template.AssetCategory = eStrategyAssetCategory_Mobile;
  Template.DefaultTeam = eTeam_Alien;
  Template.BaseInventoryCapacity = 200;
  Template.BaseUnitCapacity = 15;
  Template.HasCoreStructure = false;
  Template.GameStateClass = class'GlobalResistance_GameState_StrategyAsset';
  Template.StrategyUIClass = class'GlobalResistance_UIStrategyAsset_ResistanceCamp';

  Speed = BlankSpeed;
  Speed.ID = 'Standard';
  Speed.Velocity = 0.1;

  Template.Speeds.AddItem(Speed);

  return Template;
}


defaultproperties
{
  GeneClinicName="GeneClinic"
  RecruitmentCentreName="RecruitmentCentre"
  SupplyCentreName="SupplyCentre"
}
