/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore
using fwt
using gfx

class TagTableModel : TableModel
{
  TagLib? tagLib
  const Str tagName := "Name"
  const Str tagKind := "Kind"
  const Int desktopFontSize := Desktop.sysFont.size.toInt

  Tag[] rows := [,]
  Str[] cols := [tagName,tagKind]

  new make(File tagLib)
  {
    this.tagLib = TagLib.fromXml(tagLib)
    rows = this.tagLib.tags
  }

  new makeFromTagLibFiles(File[] libs)
  {
    Tag[] rowsoftags := [,]
    libs.each |lib|
    {
      rowsoftags.addAll(TagLib.fromXml(lib).tags)
    }
    rows = rowsoftags
  }

  Void update(File tagLib)
  {
    this.tagLib = TagLib.fromXml(tagLib)
    rows = this.tagLib.tags
  }


  Tag getRow(Int selected)
  {
    return rows[selected]
  }

  Tag[] getRows(Int[] selected)
  {
    toreturn := [,]
    selected.each |index|
    {
      toreturn.push(rows[index])
    }
    return toreturn
  }

  override Int numRows(){return rows.size}
  override Int numCols(){return cols.size}

  override Str text(Int col, Int row)
  {
    switch(cols[col])
    {
      case tagName:
      return rows[row].name
      case tagKind:
      return rows[row]->kind?:"" // unable to remove dynamic invoke, by pulling down kind member, because of serializable of classes
      default:
      return ""
    }
  }

  override Color? bg(Int col, Int row)
  {
    switch(text(1,row))
    {
      case "Marker": return Color("#c2e1ff")
      case "Ref": return Color("#fdf6b5")
      case "Str": return Color("#bbfdb5")
      case "Num": return Color("#a5dea5")
      default: return null
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

  override Str header(Int col)
  {
    return cols[col]
  }

}
