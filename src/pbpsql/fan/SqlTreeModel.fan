/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

 using fwt
 using gfx

class SqlTreeModel : TreeModel
{
  Obj? rooter
  new make(Obj rooter)
  {
    this.rooter = rooter
  }
  override Obj[] roots()
  {
    return rooter->children
  }
  override Obj[] children(Obj node)
  {
    return node->children
  }
  override Str text(Obj node)
  {
    return node->name
  }
}

