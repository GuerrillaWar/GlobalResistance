class GlobalResistance_Earth extends XComEarth config(GameCore);


function SetCurrentZoomLevel(float fZoom)
{
	//Put some limits on zoom so you can't zoom through the world or to infinity and beyond
	fTargetZoom = FClamp(fZoom, 0.30, 1.75);

	// determine the speed. Interpolation duration <= 0 disables interpolation, so if that is the case,
	// just set the zoom speed to 0 as well
	fZoomInterpolationSpeed = fZoomInterpolationDuration > 0.0f ? (abs(fTargetZoom - fCurrentZoom) * (1.0f / (fZoomInterpolationDuration))) : 0.0f;
}

function ApplyImmediateZoomOffset(float fZoomOffset)
{
	//Put some limits on zoom so you can't zoom through the world or to infinity and beyond
	fTargetZoom += fZoomOffset;
	fTargetZoom = FClamp(fTargetZoom, 0.30, 1.75);

	// No interpolation for 1:1 zooming operations; interpolation will be re-applied from setting on next
	// call of SetCurrentZoomLevel if switching to eg. Mouse Wheel
	fZoomInterpolationSpeed = 0.0f;
}


simulated event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
  fCameraPitchScalar = 1.0f;
}
