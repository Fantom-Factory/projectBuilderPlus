/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

class ApplyTableModel : TableModel, Rankable, MovableModel
{
const Int desktopFontSize := Desktop.sysFont.size.toInt
  DisApply[] applies
  Str[] columns := ["Rank", "Description", "Type"]
  new make(DisApply[] applies)
  {
    this.applies = applies
  }
  override Str text(Int col, Int row)
  {
    switch(col)
    {
      case 0:
      return row.toStr
      case 1:
      return applies[row].desc()
      case 2:
      return applies[row].typeof.name
      default:
      return ""
    }
  }
  override Int numCols() {return columns.size}
  override Int numRows() {return applies.size}
  override Str header(Int col){return columns[col]}
  override Int? prefWidth(Int col)
  {
    Int startingsize := header(col).size*desktopFontSize
    //Int startingsize := Desktop.sysFont.width(header(col))
    Int prefsize := startingsize
    applies.each |row, index|
    {
      Str field := text(col, index)
      if(field.size* desktopFontSize > prefsize)
      {
        prefsize = field.size*desktopFontSize
        if(prefsize>333)
        {
          prefsize=333
        }
      }
    }
    return prefsize
  }

  override Void moveup(Int[] selected)
  {
    applies = upgrade(applies, selected[0])
  }

  override Void movedown(Int[] selected)
  {
    applies = downgrade(applies, selected[0])
  }
}
