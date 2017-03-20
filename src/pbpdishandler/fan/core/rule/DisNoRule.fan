/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore

@Serializable
class DisNoRule : DisRule
{
  override Bool check(Record rec)
  {
    return true
  }
  override Str desc()
  {
    return "This is a no operation rule, always returns true"
  }
}

