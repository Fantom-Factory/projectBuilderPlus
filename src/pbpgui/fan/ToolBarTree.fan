/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

class ToolBarTree : EdgePane
{
  ToolBarLeftRight toolbar

  Tree tree

  new make(|This|? f)
  {
   if(f!=null)
    f(this)
   top = toolbar
   center = tree
  }
}


