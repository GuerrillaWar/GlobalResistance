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
  CreateNewArctic(Templates);
  CreateNorthAsia(Templates);

  CreateEastEurope(Templates);
  CreateWestEurope(Templates);

  CreateEastAfrica(Templates);
  CreateWestAfrica(Templates);
  CreateSouthAfrica(Templates);

  CreateSouthSA(Templates);
  CreateNorthSA(Templates);

  CreateSouthNA(Templates);
  CreateWestNA(Templates);
  CreateEastNA(Templates);

  return Templates;
}

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
  Assets.AddItem(CreateCity('NewDelhi', -28.5272, 77.1389, true)); // to north asia
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

static function CreateNewArctic(out array<X2DataTemplate> Assets)
{
  Assets.AddItem(CreateCity('Magadan', -59.5675, 150.7512, true)); // to america
  Assets.AddItem(CreateCity('Yakutsk', -62.0328, 129.5661, true)); // to east asia
  Assets.AddItem(CreateGuardPost('GP_NewArcticUstNera', -64.5615, 143.2114));
  Assets.AddItem(CreateGuardPost('GP_NewArcticBatagay', -67.6625, 134.6521));
  Assets.AddItem(CreateGuardPost('GP_NewArcticVilyuysk', -63.7491, 121.5951,true)); // to north asia
}

static function CreateNorthAsia(out array<X2DataTemplate> Assets)
{
  Assets.AddItem(CreateCity('Surgut', -61.2837, 73.2422)); 
  Assets.AddItem(CreateCity('Polnovat', -63.7819, 65.9141, true)); // to east europe
  Assets.AddItem(CreateGuardPost('GP_NAsiaLongyugan', -64.7833, 70.9394));
  Assets.AddItem(CreateGuardPost('GP_NAsiaTolka', -63.4061, 80.1040, true)); // to new arctic
  Assets.AddItem(CreateGuardPost('GP_NAsiaTara', -56.8906, 74.3438, true)); // to west asia
}

static function CreateEastEurope(out array<X2DataTemplate> Assets)
{
  Assets.AddItem(CreateCity('StPetersburg', -59.9173, 30.1849));
  Assets.AddItem(CreateCity('Moscow', -55.7494, 37.3523));
  Assets.AddItem(CreateCity('Minsk', -53.8838, 27.4548, true)); // to west europe
  Assets.AddItem(CreateGuardPost('GP_EEuropeKiev', -50.4016, 30.2525));
  Assets.AddItem(CreateGuardPost('GP_EEuropeNizhny', -56.1550, 41.2453, true)); // to north asia
  Assets.AddItem(CreateGuardPost('GP_EEuropeVolgograd', -48.6703, 44.3666, true)); // to east asia
}

static function CreateWestEurope(out array<X2DataTemplate> Assets)
{
  Assets.AddItem(CreateCity('London', -51.5283, -0.3817));
  Assets.AddItem(CreateCity('Paris', -48.8587, 2.2074));
  Assets.AddItem(CreateCity('Milan', -45.4627, 9.1076, true));
  Assets.AddItem(CreateGuardPost('GP_WEuropeFrankfurt', -50.1211, 8.4964));
  Assets.AddItem(CreateGuardPost('GP_WEuropeLaRochelle', -46.1620, -1.2463, true));
  Assets.AddItem(CreateGuardPost('GP_WEuropeMontpellier', -43.6100, 3.8041));
  Assets.AddItem(CreateGuardPost('GP_WEuropeNice', -43.7030, 7.1828));
}

static function CreateEastAfrica(out array<X2DataTemplate> Assets)
{
  Assets.AddItem(CreateCity('Tehran', -35.6964, 51.0696, true));
  Assets.AddItem(CreateCity('Riyadh', -24.7241, 46.2621));
  Assets.AddItem(CreateCity('Cairo', -30.059, 31.2234));
  Assets.AddItem(CreateGuardPost('GP_EAfricaBaghdad', -33.3116, 44.2158));
  Assets.AddItem(CreateGuardPost('GP_EAfricaTabriz', -38.0802, 46.1536, true));
  Assets.AddItem(CreateGuardPost('GP_EAfricaMedina', -24.4708, 39.3373));
  Assets.AddItem(CreateGuardPost('GP_EAfricaAlGoled', -18.4890, 30.5662, true));
}

static function CreateWestAfrica(out array<X2DataTemplate> Assets)
{
  Assets.AddItem(CreateCity('Lagos', -6.5481, 3.1173));
  Assets.AddItem(CreateCity('Abuja', -9.0543, 7.2542, true));
  Assets.AddItem(CreateCity('Freetown', -8.4543, -13.2936, true));
  Assets.AddItem(CreateGuardPost('GP_WAfricaKumasi', -6.6900, -1.6861));
  Assets.AddItem(CreateGuardPost('GP_WAfricaMonrovia', -6.2957, -10.8045));
  Assets.AddItem(CreateGuardPost('GP_WAfricaBamako', -12.6125, -8.0655));
}

static function CreateSouthAfrica(out array<X2DataTemplate> Assets)
{
  Assets.AddItem(CreateCity('CapeTown', 33.9144, 18.3758, true));
  Assets.AddItem(CreateCity('PortElizabeth', 33.8010, 25.2500));
  Assets.AddItem(CreateCity('Johannesburg', 26.1715, 27.9699));
  Assets.AddItem(CreateGuardPost('GP_SAfricaHarare', 17.8165, 30.9167, true));
  Assets.AddItem(CreateGuardPost('GP_SAfricaUpington', 28.4354, 21.0684));
  Assets.AddItem(CreateGuardPost('GP_SAfricaWindhoek', 22.5637, 16.9921));
  Assets.AddItem(CreateGuardPost('GP_SAfricaGaborone', 24.6092, 25.8604));
}

static function CreateSouthSA(out array<X2DataTemplate> Assets)
{
  Assets.AddItem(CreateCity('BuenosAires', 34.6156, -58.5734));
  Assets.AddItem(CreateCity('Santiago', 33.4727, -70.7699, true));
  Assets.AddItem(CreateCity('SaoPaulo', 23.6821, -46.8754, true));
  Assets.AddItem(CreateGuardPost('GP_SouthSAAsuncion', 25.2968, -57.6681));
  Assets.AddItem(CreateGuardPost('GP_SouthSACordoba', 31.3993, -64.3344));
  Assets.AddItem(CreateGuardPost('GP_SouthSAAntofagasta', 23.6283, -70.4745));
  Assets.AddItem(CreateGuardPost('GP_SouthSASantaCruz', 17.7574, -63.2918, true));
  Assets.AddItem(CreateGuardPost('GP_SouthSAPortoAlegre', 30.1088, -51.2469));
}

static function CreateNorthSA(out array<X2DataTemplate> Assets)
{
  Assets.AddItem(CreateCity('Quito', 0.1865, -78.5706));
  Assets.AddItem(CreateCity('Bogota', -4.6482, -74.2478));
  Assets.AddItem(CreateCity('Caracas', -10.4683, -67.0304));
  Assets.AddItem(CreateGuardPost('GP_NorthSAIquitos', 3.7529, -73.3183, true));
  Assets.AddItem(CreateGuardPost('GP_NorthSACali', -3.3950, -76.5957));
  Assets.AddItem(CreateGuardPost('GP_NorthSASanCristobal', -7.7617, -72.2567));
  Assets.AddItem(CreateGuardPost('GP_NorthSATurbo', -8.0855, -76.7392, true));
}

static function CreateSouthNA(out array<X2DataTemplate> Assets)
{
  Assets.AddItem(CreateCity('MexicoCity', -19.3905, -99.4237, true));
  Assets.AddItem(CreateCity('Monterrey', -25.6487, -100.4431));
  Assets.AddItem(CreateCity('Dallas', -32.8203, -97.0115, true));
  Assets.AddItem(CreateGuardPost('GP_SouthNASanAntonio', -29.4811, -98.7945));
  Assets.AddItem(CreateGuardPost('GP_SouthNADurango', -24.0226, -104.7177));
  Assets.AddItem(CreateGuardPost('GP_SouthNAChihuahua', -28.6708, -106.2047));
  Assets.AddItem(CreateGuardPost('GP_SouthNAElPaso', -31.8108, -106.7046953, true));
}

static function CreateWestNA(out array<X2DataTemplate> Assets)
{
  Assets.AddItem(CreateCity('Portland', -45.5420, -122.9345));
  Assets.AddItem(CreateCity('Vancouver', -49.2576, -123.2639, true));
  Assets.AddItem(CreateCity('Edmonton', -53.5555, -113.7741));
  Assets.AddItem(CreateGuardPost('GP_WestNASaltLakeCity', -40.7762, -112.2006, true));
  Assets.AddItem(CreateGuardPost('GP_WestNASaskatoon', -52.1395, -106.7868, true));
  Assets.AddItem(CreateGuardPost('GP_WestNAGreatFalls', -47.5047, -111.4435));
  Assets.AddItem(CreateGuardPost('GP_WestNACalgary', -51.0127, -114.3543));
}

static function CreateEastNA(out array<X2DataTemplate> Assets)
{
  Assets.AddItem(CreateCity('Cleveland', -41.4946, -81.9860, true));
  Assets.AddItem(CreateCity('NewYork', -40.6971, -74.2598));
  Assets.AddItem(CreateCity('Washington', -38.8992, -77.1546));
  Assets.AddItem(CreateCity('Ottawa', -45.2487, -76.3606));
  Assets.AddItem(CreateGuardPost('GP_EastNAPittsburgh', -40.4312, -80.1205));
  Assets.AddItem(CreateGuardPost('GP_EastNARochester', -43.1853, -77.7565));
  Assets.AddItem(CreateGuardPost('GP_EastNAAlbany', -42.6679, -73.9507));
  Assets.AddItem(CreateGuardPost('GP_EastNABoston', -42.3132, -71.1972, true));
  Assets.AddItem(CreateGuardPost('GP_EastNASudbury', -46.5830, -81.6395, true));
  Assets.AddItem(CreateGuardPost('GP_EastNAQuebecCity', -46.8560, -71.6218));
}
