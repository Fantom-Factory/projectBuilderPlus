/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore

class MarkerField : Button,EditField
{
  override Tag tag

  new make(Tag tag) : super()
  {
    super.mode = ButtonMode.radio
    super.selected = true
    this.tag = tag
  }
  override Tag getTagFromField()
  {
    return tag
  }

}
