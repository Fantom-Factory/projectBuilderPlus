/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt

class FileConnTableModel : TableModel
{
  PbpFileConn[] conns := [,]

  const Int desktopFontSize := Desktop.sysFont.size.toInt
  override Int numRows := 0
  
  Str[] headers := ["Filename", "Format", "URI"]
  override Int numCols := headers.size


  new make(PbpFileConn[] conns := PbpFileConn[,]) : super()
  {
    update(conns)
  }

  override Int? prefWidth(Int col)
  {
    Int startingsize := header(col).size* desktopFontSize+10
    Int prefsize := startingsize
    conns.each |row, index|
    {
      Str field := text(col, index)
      if(field.size* desktopFontSize > prefsize)
      {
        prefsize = field.size* desktopFontSize
      }
    }
    return prefsize
  }

  override Str text(Int col, Int row)
  {
    conn := conns[row]
    switch (col)
    {
      case 0  : return conn.fileName
      case 1  : return conn.format
      case 2  : return conn.uri.toStr
      default : return ""
    }
  }

  override Str header(Int col)
  {
    return headers[col]  
  }

  Void update(PbpFileConn[] conns)
  {
    this.conns = conns.sort |a, b| {return a.conn.name.compareIgnoreCase(b.conn.name)}
    numRows = conns.size
  }
}
