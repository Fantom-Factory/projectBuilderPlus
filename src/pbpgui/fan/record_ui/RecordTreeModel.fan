/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore

class RecordTreeModel : TreeModel
{
  RecordTree tree
  new make(RecordTree tree)
  {
    this.tree = tree
  }

  Void update()
  {
    tree.reset()
    tree.scanProject()
    tree.save()
  }

  override Obj[] roots()
  {
    return tree.roots
  }

  override Obj[] children(Obj node)
  {
    return (node as RecordTreeNode).children
  }

  override Str text(Obj node)
  {
    RecordTreeNode treenode := node
    return treenode.record.get("dis").val.toStr
  }


}
