class GlobalResistance_GameState_AlienPsiGateStrategyAsset extends GlobalResistance_GameState_StrategyAsset;

function StaticMesh GetStaticMesh()
{
  return StaticMesh(`CONTENT.RequestGameArchetype("UI_3D.Overwold_Final.PsiGate"));
}
