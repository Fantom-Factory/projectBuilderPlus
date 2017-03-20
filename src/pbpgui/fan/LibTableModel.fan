/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

abstract class LibTableModel : TableModel
{
  abstract File libDir
  abstract File getLibFile(Int selected)
  abstract Void update()
}
