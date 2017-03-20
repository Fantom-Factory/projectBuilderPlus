/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore


class NumField : Text, EditField
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
    return NumTag{
      it.name = tag.name
      it.val = this.text //NOTE: As of 10/27/2012 haystack::Number was not serializable so have to save as String
    }
  }

}
