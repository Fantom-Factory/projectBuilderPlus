/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore

class StrField : Text, EditField
{
  override Tag tag
  new make(Tag tag) : super()
  {
    if(tag.val == null)
    {
      text = ""
    }
    else
    {
      text = tag.val.toStr
    }
    this.tag = tag
  }
  override Tag getTagFromField()
  {
    return StrTag{
      it.name = tag.name
      it.val = this.text
    }
  }

}
