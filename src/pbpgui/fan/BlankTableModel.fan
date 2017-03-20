/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

class BlankTableModel : TableModel
{

  override Int numCols(){return 0}
  override Str header(Int col)
  {
    return ""
  }



}