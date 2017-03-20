/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore
using pbpgui
using projectBuilder

@Serializable
class DisApplyUser : DisApply
{
  const Str valueToApply
  new make(|This| f)
  {
    f(this)
  }
  override Tag apply(Record rec, Tag disTag)
  {
    if(disTag.val!="")
    {
      Tag newDisTag := StrTag{name="dis"; val=disTag.val.toStr +"-"+ valueToApply}
      return newDisTag
    }
    else
    {
      Tag newDisTag := StrTag{name="dis"; val=valueToApply}
      return newDisTag
    }

  }

  Str getVal()
  {
    return valueToApply
  }

  override Str desc()
  {
    return "This will apply the user value: " + valueToApply + " to the display name"
  }
}
