class GlobalResistance_X2Item_ExpandedResources extends X2Item;

static function array<X2DataTemplate> CreateTemplates()
{
  local array<X2DataTemplate> Resources;

  Resources.AddItem(CreateProvisions());
  Resources.AddItem(CreateMunitions());
  Resources.AddItem(CreateConventionalFuel());
  Resources.AddItem(CreateMedicalSupplies());
  Resources.AddItem(CreateAbductedBodies());
  Resources.AddItem(CreateAvatarVials());

  return Resources;
}



static function X2DataTemplate CreateProvisions()
{
  local X2ItemTemplate Template;

  `CREATE_X2TEMPLATE(class'X2ItemTemplate', Template, 'Provisions');

  Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Alien_Alloy";
  Template.ItemCat = 'resource';
  Template.TradingPostValue = 1;
  Template.MaxQuantity = 100;
  Template.CanBeBuilt = false;
  Template.HideInInventory = true;

  return Template;
}


static function X2DataTemplate CreateMunitions()
{
  local X2ItemTemplate Template;

  `CREATE_X2TEMPLATE(class'X2ItemTemplate', Template, 'Munitions');

  Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Alien_Alloy";
  Template.ItemCat = 'resource';
  Template.TradingPostValue = 1;
  Template.MaxQuantity = 100;
  Template.CanBeBuilt = false;
  Template.HideInInventory = true;

  return Template;
}


static function X2DataTemplate CreateConventionalFuel()
{
  local X2ItemTemplate Template;

  `CREATE_X2TEMPLATE(class'X2ItemTemplate', Template, 'ConventionalFuel');

  Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Alien_Alloy";
  Template.ItemCat = 'resource';
  Template.TradingPostValue = 1;
  Template.MaxQuantity = 100;
  Template.CanBeBuilt = false;
  Template.HideInInventory = true;

  return Template;
}


static function X2DataTemplate CreateMedicalSupplies()
{
  local X2ItemTemplate Template;

  `CREATE_X2TEMPLATE(class'X2ItemTemplate', Template, 'MedicalSupplies');

  Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Alien_Alloy";
  Template.ItemCat = 'resource';
  Template.TradingPostValue = 1;
  Template.MaxQuantity = 100;
  Template.CanBeBuilt = false;
  Template.HideInInventory = true;

  return Template;
}


static function X2DataTemplate CreateAbductedBodies()
{
  local X2ItemTemplate Template;

  `CREATE_X2TEMPLATE(class'X2ItemTemplate', Template, 'AbductedBodies');

  Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Alien_Alloy";
  Template.ItemCat = 'resource';
  Template.MaxQuantity = 100;
  Template.CanBeBuilt = false;
  Template.HideInInventory = true;

  return Template;
}


static function X2DataTemplate CreateAvatarVials()
{
  local X2ItemTemplate Template;

  `CREATE_X2TEMPLATE(class'X2ItemTemplate', Template, 'AvatarVials');

  Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Alien_Alloy";
  Template.ItemCat = 'resource';
  Template.MaxQuantity = 100;
  Template.CanBeBuilt = false;
  Template.HideInInventory = true;

  return Template;
}
