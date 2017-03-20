/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


using gfx
using fwt
using pbplogging

class ColumnPane : EdgePane
{

  override Void onLayout()
  {
    Size space := prefSize()
    Int totalWidth := space.w
    Int interval := totalWidth/children.size
    children.each |child,index|
    {
      child.pos = Point(index*interval,0)
      child.size = Size(interval,space.h)
    }
  }

  override Size prefSize(Hints hints := Hints.defVal)
  {
    return super.prefSize(hints)
  }

}

