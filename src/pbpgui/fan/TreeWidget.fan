/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using pbpcore

class TreeWidget : ToolBarTree
{

  new make(PbpListener pbp, RecordTree rectree) : super(
  |ToolBarTree t| {
     toolbar=ToolBarLeftRight();
     tree=Tree
     {
       model=RecordTreeModel(rectree)
       multi=true;
       onAction.add |g|
       {
         EditRecFromTree(pbp).invoked(g)
       }
       onPopup.add |g|
       {
         g.popup = PbpUtil.makeRecTreePopup(pbp,g)
       }
    }
  })
  {
    toolbar.addLeftCommand(UpdateTree(tree))
    toolbar.addLeftCommand(DeleteFromTree(tree, pbp))
    toolbar.addRightCommand(RemoveTreeFunction(pbp, null))
  }
}
