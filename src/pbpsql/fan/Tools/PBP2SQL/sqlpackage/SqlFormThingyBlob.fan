/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore
using concurrent
using pbpgui
using fwt
using gfx

abstract class SqlFormThingyBlob
{
  abstract Widget[] getForm()
  abstract Void removeForm()
  abstract SqlPackageRule? processRule()
}
