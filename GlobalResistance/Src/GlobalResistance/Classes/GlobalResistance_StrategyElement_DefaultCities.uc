class GlobalResistance_StrategyElement_DefaultCities extends X2StrategyElement;

static function array<X2DataTemplate> CreateTemplates()
{
  local array<X2DataTemplate> Templates;

  Templates.AddItem(CreateMontrealTemplate());
  Templates.AddItem(CreateSantiagoTemplate());
  Templates.AddItem(CreateSeoulTemplate());

  Templates.AddItem(CreateSingaporeTemplate());
  Templates.AddItem(CreateNewDelhiTemplate());

  // AUSTRALIA Templates
  /* Templates.AddItem(CreateSydneyTemplate()); */
  /* Templates.AddItem(CreateMelbourneTemplate()); */
  /* Templates.AddItem(CreateBrisbaneTemplate()); */
  CreateAustralia(Templates);

  return Templates;
}

// 0 W Dateline
// 1 E Dateline
// 0 Northern Most
// 1 Southern Most


static function SetPositionCity(out GlobalResistance_CityTemplate Template, float Latitude, float Longitude) {
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

static function SetPositionGP(
  out GlobalResistance_GuardPostTemplate Template,
  float Latitude, float Longitude
) {
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

static function X2DataTemplate CreateCity (
  name DataName, float Latitude, float Longitude
) {
  local GlobalResistance_CityTemplate Template;
  `CREATE_X2TEMPLATE(class'GlobalResistance_CityTemplate', Template, DataName);
  SetPositionCity(Template, Latitude, Longitude);
  return Template;
}

static function X2DataTemplate CreateGuardPost (
  name DataName, float Latitude, float Longitude, bool BorderPost = false
) {
  local GlobalResistance_GuardPostTemplate Template;
  `CREATE_X2TEMPLATE(class'GlobalResistance_GuardPostTemplate', Template, DataName);
  SetPositionGP(Template, Latitude, Longitude);
  Template.BorderPost = BorderPost;
  return Template;
}

static function X2DataTemplate CreateMontrealTemplate()
{
  local GlobalResistance_CityTemplate Template;
  `CREATE_X2TEMPLATE(class'GlobalResistance_CityTemplate', Template, 'Montreal');
  SetPositionCity(Template, -45.5017, -73.5673);
  return Template;
}

static function X2DataTemplate CreateSantiagoTemplate()
{
  local GlobalResistance_CityTemplate Template;
  `CREATE_X2TEMPLATE(class'GlobalResistance_CityTemplate', Template, 'Santiago');
  SetPositionCity(Template, 33.4489, -70.6693);
  return Template;
}

static function X2DataTemplate CreateNewDelhiTemplate()
{
  local GlobalResistance_CityTemplate Template;
  `CREATE_X2TEMPLATE(class'GlobalResistance_CityTemplate', Template, 'NewDelhi');
  SetPositionCity(Template, -28.6139, 77.2090);
  return Template;
}


static function X2DataTemplate CreateSingaporeTemplate()
{
  local GlobalResistance_CityTemplate Template;
  `CREATE_X2TEMPLATE(class'GlobalResistance_CityTemplate', Template, 'Singapore');
  SetPositionCity(Template, -1.3521, 103.8198);
  return Template;
}

static function X2DataTemplate CreateSeoulTemplate()
{
  local GlobalResistance_CityTemplate Template;
  `CREATE_X2TEMPLATE(class'GlobalResistance_CityTemplate', Template, 'Seoul');
  SetPositionCity(Template, -37.5665, 126.9780);
  return Template;
}

static function CreateAustralia(out array<X2DataTemplate> Assets)
{
  Assets.AddItem(CreateCity('Sydney', 33.8688, 151.2093));
  Assets.AddItem(CreateCity('Melbourne', 37.8136, 144.9631));
  Assets.AddItem(CreateCity('Brisbane', 27.4698, 153.0251));
  Assets.AddItem(CreateGuardPost('GP_AustraliaAdelaide', 34.9285, 138.6007));
  Assets.AddItem(CreateGuardPost('GP_AustraliaCobar', 31.7015, 145.8373));
  Assets.AddItem(CreateGuardPost('GP_Darwin', 12.5827, 130.9641, true));
}
