/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore

class ProjTableModel : TableModel
{
  File projectDir
  const Int desktopFontSize := Desktop.sysFont.size.toInt
  new make(File projectDir)
  {
    this.projectDir = projectDir
    rows = projectDir.listDirs
  }

  Str[] cols := ["Project Name", "Location"]
  File[] rows

  override Str header(Int col)
  {
    return cols[col]
  }

  Void update()
  {
    rows = projectDir.listDirs
  }

  File[] getRows(Int[] selected)
  {
    File[] files := [,]
    selected.each |index|
    {
      files.push(rows[index])
    }
    return files
  }

  override Int numCols(){return cols.size}
  override Int numRows(){return rows.size}

  override Str text(Int col, Int row)
  {
    switch(col)
    {
      case 0:
        return rows[row].basename
      case 1:
        return rows[row].uri.toStr
      default:
      return ""
    }
  }

  override Int? prefWidth(Int col)
  {
    Int startingsize := header(col).size* desktopFontSize
    Int prefsize := startingsize
    rows.each |row, index|
    {
      Str field := text(col, index)
      if(field.size* desktopFontSize > prefsize)
      {
        prefsize = field.size* desktopFontSize
      }
    }
    return prefsize
  }

}
