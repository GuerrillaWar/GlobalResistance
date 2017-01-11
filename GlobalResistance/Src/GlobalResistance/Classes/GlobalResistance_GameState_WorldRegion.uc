class GlobalResistance_GameState_WorldRegion
extends XComGameState_WorldRegion;

var() array<StateObjectReference>   GuardPosts;
var() array<StateObjectReference>   Roads;

function bool ShouldBeVisible() {
  return true;
}

function array<XComGameState_WorldRegion> FindShortestPathToRegion(XComGameState_WorldRegion TargetRegion)
{
  local XComGameStateHistory History;
  local array<RegionPath> arrSearchPaths, arrSolutionPaths;
  local XComGameState_WorldRegion TestRegion, ChildRegion;
  local RegionPath StartPath, TestPath, NewPath;
  local StateObjectReference StateRef;

  History = `XCOMHISTORY;

  StartPath.Regions.AddItem(self);
  StartPath.Cost = 0;

  arrSearchPaths.AddItem(StartPath);
  
  while (arrSearchPaths.Length > 0)
  {
    // Pop nearest region off queue
    TestPath = arrSearchPaths[0];
    TestRegion = TestPath.Regions[TestPath.Regions.Length - 1];
    arrSearchPaths.Remove(0, 1);

    // If the search has started testing region paths which are longer than a potential solution, break
    // We want the smallest cost between all paths with the fewest links. If we have a short solution, don't test longer ones.
    if (arrSolutionPaths.Length > 0 && TestPath.Regions.Length > arrSolutionPaths[0].Regions.Length)
    {
      break;
    }

    // Did we find a match?
    if (TestRegion.ObjectID == TargetRegion.ObjectID)
    {
      arrSolutionPaths.AddItem(TestPath);
      continue;
    }

    foreach TestRegion.LinkedRegions(StateRef)
    {
      ChildRegion = XComGameState_WorldRegion(History.GetGameStateForObjectID(StateRef.ObjectID));
      if (TestPath.Regions.Find(ChildRegion) == INDEX_NONE)
      {
        NewPath = TestPath;
        NewPath.Regions.AddItem(ChildRegion);
        NewPath.Cost += 1;

        arrSearchPaths.AddItem(NewPath);
      }
    }
  }

  NewPath = StartPath; // Reset NewPath to match StartPath
  NewPath.Cost = -1; // Then use it to try and the lowest cost Best Path
  foreach arrSolutionPaths(TestPath)
  {
    if (NewPath.Cost == -1)
    {
      NewPath = TestPath;
    }
    else if (TestPath.Cost < NewPath.Cost)
    {
      NewPath = TestPath;
    }
  }

  return NewPath.Regions;
}
