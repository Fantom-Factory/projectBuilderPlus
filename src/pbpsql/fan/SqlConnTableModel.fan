/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

class SqlConnTableModel : TableModel
{
    SqlPool sqlPool

    new make(SqlPool sqlPool)
    {
      this.sqlPool = sqlPool
      rows = sqlPool.listConns
    }

    Str[] rows
    Str[] cols := ["Name","Status"]

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
      switch(cols[col])
      {
        case "Name":
          return rows[row]
        case "Status":
          return sqlPool.getSqlConn(rows[row]).statusLabel.text.split(':').get(1)
        default:
          return ""
      }
    }

    override Str header(Int col)
    {
      return cols[col]
    }

    SqlConnWrapper getConn(Int[] selected)
    {
        return sqlPool.getSqlConn(rows[selected.first])
    }

    Void update(SqlPool sqlPool)
    {
      this.sqlPool = sqlPool
      rows = sqlPool.listConns
      return
    }


}
