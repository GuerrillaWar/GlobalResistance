class GlobalResistance_StrategyElement_DefaultCities extends X2StrategyElement;

static function array<X2DataTemplate> CreateTemplates()
{
  local array<X2DataTemplate> Templates;

  Templates.AddItem(CreateMontrealTemplate());
  Templates.AddItem(CreateSantiagoTemplate());

  CreateAustralia(Templates);
  CreateSouthEastAsia(Templates);
  CreateSouthAsia(Templates);
  CreateEastAsia(Templates);

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
  name DataName, float Latitude, float Longitude, bool BorderCity = false
) {
  local GlobalResistance_CityTemplate Template;
  `CREATE_X2TEMPLATE(class'GlobalResistance_CityTemplate', Template, DataName);
  SetPositionCity(Template, Latitude, Longitude);
  Template.BorderCity = BorderCity;
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

static function CreateSouthAsia(out array<X2DataTemplate> Assets)
{
  Assets.AddItem(CreateCity('Kolkata', -22.6756, 88.2285, true));
  Assets.AddItem(CreateCity('NewDelhi', -28.5272, 77.1389, true));
  Assets.AddItem(CreateCity('Karachi', -25.0001, 66.9246, true));
  Assets.AddItem(CreateGuardPost('GP_SAsiaKathmandu', -27.7089, 85.2911));
  Assets.AddItem(CreateGuardPost('GP_SAsiaMumbai', -19.0827, 72.7411));
  Assets.AddItem(CreateGuardPost('GP_SAsiaNagpur', -21.1610, 79.0024));
  Assets.AddItem(CreateGuardPost('GP_SAsiaChennai', -13.0475, 80.0689));
}

static function CreateEastAsia(out array<X2DataTemplate> Assets)
{
  Assets.AddItem(CreateCity('Shanghai', -31.2240, 121.1965, true));
  Assets.AddItem(CreateCity('Seoul', -37.5665, 126.9780));
  Assets.AddItem(CreateCity('Tokyo', -35.6691, 139.6012));
  Assets.AddItem(CreateGuardPost('GP_EAsiaOsaka', -34.6783, 135.4776));
  Assets.AddItem(CreateGuardPost('GP_EAsiaSapporo', -43.0594, 141.3354));
  Assets.AddItem(CreateGuardPost('GP_EAsiaBeijing', -39.9385, 116.1172));
  Assets.AddItem(CreateGuardPost('GP_EAsiaChangchun', -43.6509, 126.6662, true));
  Assets.AddItem(CreateGuardPost('GP_EAsiaZhengzhou', -34.7425, 113.5230, true));
}

static function CreateSouthEastAsia(out array<X2DataTemplate> Assets)
{
  Assets.AddItem(CreateCity('Singapore', -1.3521, 103.8198));
  Assets.AddItem(CreateCity('Manila', -14.5964, 120.9619, true));
  Assets.AddItem(CreateCity('HoChiMinhCity', -10.7680, 106.4141));
  Assets.AddItem(CreateGuardPost('GP_SEAsiaJakarta', 6.2297, 106.7594));
  Assets.AddItem(CreateGuardPost('GP_SEAsiaMakassar', 5.1227, 119.3912, true));
  Assets.AddItem(CreateGuardPost('GP_SEAsiaBangkok', -13.7245, 100.4930, true));
}

static function CreateAustralia(out array<X2DataTemplate> Assets)
{
  Assets.AddItem(CreateCity('Sydney', 33.8688, 151.2093));
  Assets.AddItem(CreateCity('Melbourne', 37.8136, 144.9631));
  Assets.AddItem(CreateCity('Brisbane', 27.4698, 153.0251, true));
  Assets.AddItem(CreateGuardPost('GP_AustraliaAdelaide', 34.9285, 138.6007));
  Assets.AddItem(CreateGuardPost('GP_AustraliaCobar', 31.7015, 145.8373));
  Assets.AddItem(CreateGuardPost('GP_AustraliaTownsville', 19.2966, 146.6851));
  Assets.AddItem(CreateGuardPost('GP_AustraliaAliceSprings', 23.6993, 133.8757));
  Assets.AddItem(CreateGuardPost('GP_AustraliaDarwin', 12.5827, 130.9641, true));
}
