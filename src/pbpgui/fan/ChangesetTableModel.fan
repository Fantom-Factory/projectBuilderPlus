/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore

class ChangesetTableModel : TableModel
{
  PbpListener pbp
  Project? project
  File[] rows := [,]
  Str[] cols := ["Date"]
  new make(PbpListener pbp)
  {
    this.pbp = pbp
    project = pbp.prj
    update()
  }

File[] getRows(Int[] selected)
{
  File[] toReturn := [,]
  selected.each |select|
  {
    toReturn.push(rows[select])
  }
  return toReturn
}
  override Int numCols()
  {
    return cols.size
  }

  override Int numRows()
  {
    return rows.size
  }

  Void update()
  {
    if (pbp.prj != null)
    {
    this.project = pbp.prj
    rows = project.changeDir.listFiles.findAll|File f->Bool|{return f.ext=="changes"}
    }
  }

  override Str text(Int col, Int row)
  {
    return rows[row].basename
  }

  override Str header(Int col)
  {
    return cols[col]
  }


}
