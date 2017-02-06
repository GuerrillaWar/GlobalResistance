class GlobalResistance_UIMouseGuard_StrategyMap extends UIMouseGuard;

var Vector2D MouseLocation;
var bool bAvengerMovementMode;
var Vector MouseWorldOrigin, MouseWorldDirection;

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	super.InitScreen(InitController, InitMovie, InitName);

  // needed to register PostRenderFor
  AddHUDOverlayActor();
}


simulated event PostRenderFor(PlayerController kPC, Canvas kCanvas, vector vCameraPosition, vector vCameraDir)
{
  Movie.Pres.m_kUIMouseCursor.UpdateMouseLocation();
  MouseLocation = Movie.Pres.m_kUIMouseCursor.m_v2MouseLoc;
  kCanvas.DeProject(MouseLocation, MouseWorldOrigin, MouseWorldDirection);
  // first wierd thing, this only runs when I comment it.
  `log("Deprojection running");
  `log("DeprojectOrigin:" @ MouseWorldOrigin.X @ MouseWorldOrigin.Y);
  `log("DeprojectDirection:" @ MouseWorldDirection.X @ MouseWorldDirection.Y);
}

simulated function OnMouseEvent(int cmd, array<string> args)
{
  local Vector HitLocation, HitNormal, WTL, WTR, WBL, WBR;
  local Vector2D EarthLocation, ETL, ETR, EBL, EBR;
  local TraceHitInfo TraceInfo;
  local XComEarth kEarth;
	local XComGameState NewGameState;
	local XComGameState_HeadquartersXCom XComHQ;
	local GlobalResistance_GameState_TravelPin TravelPin;

  super.OnMouseEvent(cmd, args);

  switch( cmd )
  {
  case class'UIUtilities_Input'.const.FXS_L_MOUSE_UP:
    ETL.X = 0;
    ETL.Y = 0;
    ETR.X = 1;
    ETR.Y = 0;
    EBL.X = 0;
    EBL.Y = 1;
    EBR.X = 1;
    EBR.Y = 1;

    kEarth = `EARTH;
    WTL = kEarth.ConvertEarthToWorld(ETL);
    WTR = kEarth.ConvertEarthToWorld(ETR);
    WBL = kEarth.ConvertEarthToWorld(EBL);
    WBR = kEarth.ConvertEarthToWorld(EBR);

    kEarth.SetCurvature(0.0f, false);
    // usse TraceActors instead and keep a nice long line on the trace
    kEarth.Trace(HitLocation, HitNormal,
                 MouseWorldOrigin + (MouseWorldDirection * 1024),
                 MouseWorldOrigin, true,,TraceInfo);

    EarthLocation = kEarth.ConvertWorldToEarth(HitLocation);

    `log("World Bounds: Top Left:" @ WTL);
    `log("World Bounds: Top Right:" @ WTR);
    `log("World Bounds: Bottom Left:" @ WBL);
    `log("World Bounds: Bottom Right:" @ WBR);
    `log("WHAT WE HIT:" @ TraceInfo.HitComponent);

    `log("Movement Click received:" @ MouseLocation.X @ MouseLocation.Y);
    `log("World Location received:" @ HitLocation.X @ HitLocation.Y);
    `log("Hit Normal received:" @ HitNormal.X @ HitNormal.Y);
    `log("Earth Location received:" @ EarthLocation.X @ EarthLocation.Y);

    NewGameState = class'XComGameStateContext_ChangeContainer'.static
      .CreateChangeState("Create temp Geoscape Entity for Travel");

    TravelPin = GlobalResistance_GameState_TravelPin(
      NewGameState.CreateStateObject(
        class'GlobalResistance_GameState_TravelPin'
      )
    );
    TravelPin.Location.X = EarthLocation.X;
    TravelPin.Location.Y = EarthLocation.Y;
    NewGameState.AddStateObject(TravelPin);
    `XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
    `XCOMHQ.SetPendingPointOfTravel(TravelPin);
    `SCREENSTACK.Pop(self);
    break;
  }
}

