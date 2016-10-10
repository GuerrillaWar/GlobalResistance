class GlobalResistance_StrategyElement_DefaultCities extends X2StrategyElement;

static function array<X2DataTemplate> CreateTemplates()
{
  local array<X2DataTemplate> Cities;

  Cities.AddItem(CreateMontrealTemplate());
  Cities.AddItem(CreateSantiagoTemplate());
  Cities.AddItem(CreateSeoulTemplate());

  // AUSTRALIA Cities
  Cities.AddItem(CreateSydneyTemplate());
  Cities.AddItem(CreateMelbourneTemplate());
  Cities.AddItem(CreateBrisbaneTemplate());
  Cities.AddItem(CreatePerthTemplate());

  return Cities;
}

// 0 W Dateline
// 1 E Dateline
// 0 Northern Most
// 1 Southern Most


static function SetPosition(out GlobalResistance_CityTemplate Template, float Latitude, float Longitude) {
  local float MercX, MercY;
  if (Latitude > 89.5) { Latitude = 89.5; }
  if (Latitude < -89.5) { Latitude = -89.5; }

  MercX = (Longitude + 180) / 360;
  MercY = (Latitude + 90) / 180;

  `log("Latitude: " @ Latitude @ "-" @ MercY);
  `log("Longitude: " @ Longitude @ "-" @ MercX);

  Template.Location.y = MercY;
  Template.Location.x = MercX - 0.04; // global seeming X offset
}

static function X2DataTemplate CreateMontrealTemplate()
{
  local GlobalResistance_CityTemplate Template;
  `CREATE_X2TEMPLATE(class'GlobalResistance_CityTemplate', Template, 'Montreal');
  SetPosition(Template, -45.5017, -73.5673);
  return Template;
}

static function X2DataTemplate CreateSantiagoTemplate()
{
  local GlobalResistance_CityTemplate Template;
  `CREATE_X2TEMPLATE(class'GlobalResistance_CityTemplate', Template, 'Santiago');
  SetPosition(Template, 33.4489, -70.6693);
  return Template;
}

static function X2DataTemplate CreateSeoulTemplate()
{
  local GlobalResistance_CityTemplate Template;
  `CREATE_X2TEMPLATE(class'GlobalResistance_CityTemplate', Template, 'Seoul');
  SetPosition(Template, -37.5665, 126.9780);
  return Template;
}

static function X2DataTemplate CreateSydneyTemplate()
{
  local GlobalResistance_CityTemplate Template;
  `CREATE_X2TEMPLATE(class'GlobalResistance_CityTemplate', Template, 'Sydney');
  SetPosition(Template, 33.8688, 151.2093);
  return Template;
}

static function X2DataTemplate CreateMelbourneTemplate()
{
  local GlobalResistance_CityTemplate Template;
  `CREATE_X2TEMPLATE(class'GlobalResistance_CityTemplate', Template, 'Melbourne');
  SetPosition(Template, 37.8136, 144.9631);
  return Template;
}

static function X2DataTemplate CreateBrisbaneTemplate()
{
  local GlobalResistance_CityTemplate Template;
  `CREATE_X2TEMPLATE(class'GlobalResistance_CityTemplate', Template, 'Brisbane');
  SetPosition(Template, 27.4698, 153.0251);
  return Template;
}

static function X2DataTemplate CreatePerthTemplate()
{
  local GlobalResistance_CityTemplate Template;
  `CREATE_X2TEMPLATE(class'GlobalResistance_CityTemplate', Template, 'Perth');
  SetPosition(Template, 31.9505, 115.8605);
  return Template;
}
