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
class DisNoApply : DisApply
{
  override Tag apply(Record rec, Tag disTag)
  {
    return disTag
  }
  override Str desc()
  {
    return "This is a no-op apply"
  }
}
