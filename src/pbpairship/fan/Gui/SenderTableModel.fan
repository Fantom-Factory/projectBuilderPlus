/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using airship

class SenderTableModel : TableModel
{
  PackageSender[] rows
  Str[] cols := ["Name","Type","Id"]
  new make()
  {
    rows = (Env.cur.homeDir+`etc/pbpairship/`).listFiles.findAll |File f->Bool| {return f.ext=="sender"}.map|File f->PackageSender|{return f.readObj}
  }

  Void update()
  {
     rows = (Env.cur.homeDir+`etc/pbpairship/`).listFiles.findAll |File f->Bool| {return f.ext=="sender"}.map|File f->PackageSender|{return f.readObj}
  }

  override Int numRows()
  {
    return rows.size
  }

  override Int numCols()
  {
    return cols.size
  }

  override Str text(Int col, Int row)
  {
    switch(col)
    {
      case 0:
        return rows[row] is SqlToSkysparkSender ? (rows[row] as SqlToSkysparkSender).options.get("name") : ""
      case 1:
        return rows[row].typeof.name
      case 2:
        return rows[row].id
      default:
        return ""
    }
  }

  override Str header(Int col)
  {
    return cols[col]
  }
}
