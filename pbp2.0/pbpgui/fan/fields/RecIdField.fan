/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using haystack
using pbpcore

class RefField : Text, EditField
{
  override Tag tag
  new make(RefTag tag) : super()
  {
    editable=true
    this.tag = tag
    if(tag.val == null)
    {
      text = Ref.nullRef.toStr
    }
    else
    {
      text = tag.val.toStr
    }
  }

  override Tag getTagFromField()
  {
    return RefTag{
      it.name = tag.name
      it.val = Ref.fromStr(this.text)
    }
  }

}
