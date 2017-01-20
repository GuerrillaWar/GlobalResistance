class GlobalResistance_StrategyAssetTemplate extends X2StrategyElementTemplate;

enum StrategyAssetCategory
{
  eStrategyAssetCategory_Static,
  eStrategyAssetCategory_Buildable,
  eStrategyAssetCategory_Mobile,
};


struct StrategyAssetSpeed
{
  var name ID;
  var string FriendlyName;
  var bool TraverseAir;
  var bool TraverseGroundRoad;
  var bool TraverseGroundJungle;
  var bool TraverseGroundMountain;
  var bool TraverseSea;
  var float Velocity;
};


struct StrategyAssetUpkeepDefinition
{
  var array<ArtifactCost> Cost;
  var array<name> Penalties;
  var int UpkeepFrequency;
  var name UpkeepID;
}


struct StrategyAssetProductionDefinition
{
  var array<ArtifactCost> Inputs;
  var array<ArtifactCost> Outputs;
  var int ProductionTime; // hours
  var name ProductionID;
};



struct StrategyAssetStructureDefinition
{
  var name ID;

  // BUILD PARAMS
  var int BuildHours;
  var array<ArtifactCost> BuildCost;
  var StrategyRequirement BuildRequirements;

  // ONGOING PARAMS
  var array<StrategyAssetProductionDefinition> Production;
  var array<StrategyAssetUpkeepDefinition> Upkeep;

  // STORAGE PARAMS
  var int UnitCapacity;
  var int InventoryCapacity;

  // MISSION PARAM
  var array<name> ParcelObjectiveTags;
  var array<name> PCPObjectiveTags;
};



var StrategyAssetCategory AssetCategory;
var eTeam DefaultTeam;
var int InventoryCapacity;
var int UnitCapacity;
var array<StrategyAssetUpkeepDefinition> Upkeep;
var array<StrategyAssetProductionDefinition> Production;

var bool HasCoreStructure;
var StrategyAssetStructureDefinition CoreStructure; // must be immediately built if this is assetCategory Buildable;
var array<StrategyAssetStructureDefinition> AllowedStructures;
var array<StrategyAssetSpeed> Speeds;
var class<GlobalResistance_GameState_StrategyAsset> GameStateClass;
var class<GlobalResistance_UIStrategyAsset> StrategyUIClass;

var array<name> PlotTypes;


delegate int CalculateInventoryCapacityDelegate(GlobalResistance_GameState_StrategyAsset Asset);
delegate int CalculateUnitCapacityDelegate(GlobalResistance_GameState_StrategyAsset Asset);
delegate array<StrategyAssetUpkeep> CalculateUpkeep(GlobalResistance_GameState_StrategyAsset Asset);
delegate array<StrategyAssetProduction> CalculateProduction(GlobalResistance_GameState_StrategyAsset Asset);






function StrategyAssetStructureDefinition GetStructureDefinition(name StructureType)
{
  local StrategyAssetStructureDefinition StructureDef;
  foreach AllowedStructures(StructureDef)
  {
    if (StructureDef.ID == StructureType)
    {
      return StructureDef;
    }
  }
}
