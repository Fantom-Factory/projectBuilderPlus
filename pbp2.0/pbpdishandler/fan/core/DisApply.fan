/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore
using pbpgui
using projectBuilder

abstract class DisApply
{
  abstract Tag apply(Record rec, Tag disTag)
  abstract Str desc()
}


