/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////




class TagLibTableModel : LibTableModel
{
  Str ext := "taglib"
  File[] rows
  File? defaultLib
  Str[] cols := ["Name","Type","Default"]
  const Int nameCol := 0
  const Int typeCol := 1
  const Int defaultCol := 2

  override File libDir

  new make(File libDir, File? defaultLib)
  {
    this.libDir = libDir
    this.defaultLib = defaultLib
    this.rows = libDir.listFiles.findAll|File f->Bool| {return f.ext == this.ext}
  }

  override Int numCols()
  {
    return cols.size
  }

  override Int numRows()
  {
    return rows.size
  }

  override Str text(Int col, Int row)
  {
    switch(col)
    {
      case nameCol:
        return rows[row].basename
      case typeCol:
        return rows[row].ext
      case defaultCol:
        return rows[row] == defaultLib ? "#" : ""
      default:
        return ""
    }
  }

  override Str header(Int col)
  {
    return cols[col]
  }

  override Void update()
  {
    rows = libDir.listFiles.findAll|File f->Bool| {return f.ext == this.ext}
  }

  override File getLibFile(Int selected)
  {
    return rows[selected]
  }

}
