/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using sql
using fwt
using gfx

class SqlTableModel : TableModel{

  override Int numCols
  override Int numRows
  const Int DESKTOP_FONT_SIZE := Desktop.sysFont.size.toInt
  const Int MAX_COLUMN_WIDTH := 200
  SqlRow[] rows
  SqlCol[] cols
  new make()
  {
    //init rows and cols
    rows = [,]
    cols = [,]
    cols.sort
    numRows = rows.size
    numCols = cols.size
  }

  Void update(SqlRow[] sqlrows)
  {
   //init rows and cols
    rows = [,]
    cols = [,]
    if(sqlrows.size > 0)
    {
    cols.addAll(sqlrows[0].cols)
    sqlrows.each |sqlr|{
      rows.push(sqlr)
      }
    }
    numRows = rows.size
    numCols = cols.size
  }

  override Str header(Int col)
  {
    return cols[col].name
  }

  override Str text(Int col, Int row)
  {
    if(rows[row].data.containsKey(header(col)) && rows[row].data[header(col)] != null)
    {
      return rows[row].data[header(col)].toStr
    }
    else
    {
      return ""
    }
  }

   override Int? prefWidth(Int col)
  {
    Int startingsize := header(col).size*DESKTOP_FONT_SIZE+20
    Int prefsize := startingsize
    rows.each |row, index|
    {
      if(row.data.containsKey(header(col)) && row.data[header(col)]!=null)
      {
      Int temp := row.data[header(col)].toStr.size*DESKTOP_FONT_SIZE+20
      if(temp > prefsize)
      {
        prefsize = temp
      }
      }
    }
    return prefsize <= MAX_COLUMN_WIDTH ? prefsize : startingsize
  }

}

