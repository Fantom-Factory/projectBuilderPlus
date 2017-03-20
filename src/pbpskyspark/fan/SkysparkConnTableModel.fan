/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore

class SkysparkConnTableModel : TableModel
{

  SkysparkConn[] rows
  Str[] cols := ["Name", "Status"]
  const Int nameCol := 0
  const Int statusCol := 1
  SkysparkConnManager connManager
  new make(SkysparkConnManager connManager)
  {
    this.connManager = connManager
    rows = connManager.connPool.conns

  }

  Void update()
  {
    if(connManager.pbp.currentProject != null)
    {
      //update via current project's conn folder
      connManager.connPool.conns.clear
      connManager.pbp.currentProject.connDir.listFiles.findAll|File f->Bool|{return f.ext=="skyconn"}.each |connfile|
      {
        connManager.connPool.addConn(SkysparkConn.fromXml(connfile, connManager.pbp.licenseInfo))
        connManager.connPool.conns.peek.projectName = connManager.pbp.currentProject.name
      }
      rows = connManager.connPool.conns
    }
  }

  SkysparkConn[] getRows(Int[] selected)
  {
    SkysparkConn[] conns := [,]
    selected.each |index|
    {
      conns.push(rows[index])
    }
    return conns
  }

  override Int numCols()
  {
    return cols.size
  }

  override Int numRows()
  {
    return rows.size
  }

  override Str header(Int col)
  {
    return cols[col]
  }

  override Str text(Int col, Int row)
  {
    switch(col)
    {
      case nameCol:
        return rows[row].dis
      case statusCol:
        if(rows[row].status)
        {
          return "Connected"
        }
        else
        {
          return "Error"
        }
      default:
      return ""
    }
  }

  override Image? image(Int col, Int row)
  {
    switch(col)
    {
      case nameCol:
        return null
      case statusCol:
        if(rows[row].status)
        {
          return Image(`fan://icons/x16/check.png`)
        }
        else
        {
          return Image(`fan://icons/x16/err.png`)
        }
      default:
      return null
    }
  }

}
