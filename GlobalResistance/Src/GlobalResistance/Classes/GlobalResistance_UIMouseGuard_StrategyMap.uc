class GlobalResistance_UIMouseGuard_StrategyMap extends UIMouseGuard;

var Vector2D MouseLocation;
var bool bAvengerMovementMode;

simulated function OnMouseEvent(int cmd, array<string> args)
{
  super.OnMouseEvent(cmd, args);

  switch( cmd )
  {
  case class'UIUtilities_Input'.const.FXS_L_MOUSE_UP:
    Movie.Pres.m_kUIMouseCursor.UpdateMouseLocation();
    MouseLocation = Movie.Pres.m_kUIMouseCursor.m_v2MouseLoc;
    `log("Movement Click received:" @ MouseLocation.X @ MouseLocation.Y);
    `SCREENSTACK.Pop(self);
    break;
  }
}
