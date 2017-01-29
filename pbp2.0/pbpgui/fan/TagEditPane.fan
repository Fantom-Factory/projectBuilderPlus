/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

class TagEditPane : GridPane
{

  new make(|This| f)
  {
    f(this)
  }

  override This add(Widget? widget)
  {
    super.add(widget)
    this.relayout
    return this
  }

}
