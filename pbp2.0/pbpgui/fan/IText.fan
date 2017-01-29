/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

class IText : Text
{
  new make(|This| f):super(f)
  {
  }

  override Size prefSize(Hints hints := Hints.defVal)
  {
    return Size(297,20)
  }

}
