/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

class UpdateTree : Command
{
  Tree tree
  new make(Tree tree) : super.makeLocale(Pod.find("projectBuilder"),"refreshTree")
  {
    this.tree = tree
  }

  override Void invoked(Event? e)
  {
    (tree.model as RecordTreeModel).update()
    //tree.refreshNode(tree.model->tree->latestNode)
    tree.refreshAll
  }

}

