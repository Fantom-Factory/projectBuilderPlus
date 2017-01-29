/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using airship
using projectBuilder

class ReceiverTableModel : TableModel
{
  PackageReceiver[] rows
  Str[] cols := ["Name","Type","Id"]

    private LicenseInfo licenseInfo

  new make(LicenseInfo licenseInfo)
  {
        this.licenseInfo = licenseInfo
        this.rows = createRows
  }

  Void update()
  {
    rows = createRows
  }

  private PackageReceiver[] createRows()
  {
    return (Env.cur.homeDir+`etc/pbpairship/`).listFiles.findAll |File f->Bool| {return f.ext=="receiver"}.map|File f->PackageReceiver|
    {
      return f.readObj(["makeArgs": [licenseInfo]])
    }
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
        return rows[row].toStr
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
