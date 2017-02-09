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
}

simulated function OnMouseEvent(int cmd, array<string> args)
{
  local Vector HitLocation, HitNormal;
  local Vector2D EarthLocation;
  local TraceHitInfo TraceInfo;
  local XComEarth kEarth;
	local XComGameState NewGameState;
  local XComLevelActor HitActor;
	local XComGameState_HeadquartersXCom XComHQ;
	local GlobalResistance_GameState_TravelPin TravelPin;
  local bool bFound;

  super.OnMouseEvent(cmd, args);

  switch( cmd )
  {
  case class'UIUtilities_Input'.const.FXS_L_MOUSE_UP:

    kEarth = `EARTH;
    // usse TraceActors instead and keep a nice long line on the tr
    foreach kEarth.TraceActors(class'XComLevelActor',
                                HitActor,
                                HitLocation,
                                HitNormal,
                                MouseWorldOrigin + (MouseWorldDirection * 1024),
                                MouseWorldOrigin,
                                vect(0,0,0),
                                TraceInfo,
                                TRACEFLAG_Bullet)
    {
        `log(PathName(HitActor));
        if (HitActor.Tag == 'OverworldMesh')
        {
            bFound = true;
            break;
        }
    }
    if (!bFound)
    {
        return;
    }

    EarthLocation = kEarth.ConvertWorldToEarth(HitLocation);

    `log("WHAT WE HIT:" @ PathName(TraceInfo.HitComponent));
    `log("Movement Click received:" @ MouseLocation.X @ MouseLocation.Y);
    `log("World Location received:" @ HitLocation.X @ HitLocation.Y);
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
    CloseScreen();
    break;
  }
}

