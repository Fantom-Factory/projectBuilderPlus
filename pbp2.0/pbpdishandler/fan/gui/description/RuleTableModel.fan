/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

class RuleTableModel : TableModel, Rankable, MovableModel
{
  DisRule[] rules
  Str[] columns := ["Rank", "Description", "Type"]
  const Int desktopFontSize := Desktop.sysFont.size.toInt
  new make(DisRule[] rules)
  {
    this.rules = rules
  }
  override Str text(Int col, Int row)
  {
    switch(col)
    {
      case 0:
      return row.toStr
      case 1:
      return rules[row].desc()
      case 2:
      return rules[row].typeof.name
      default:
      return ""
    }
  }
  override Int numCols() {return columns.size}
  override Int numRows() {return rules.size}
  override Str header(Int column)
  {
    return columns[column]
  }
  override Int? prefWidth(Int col)
  {
    Int startingsize := header(col).size*desktopFontSize
    //Int startingsize := Desktop.sysFont.width(header(col))
    Int prefsize := startingsize
    rules.each |row, index|
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
    rules = upgrade(rules, selected[0])
  }

  override Void movedown(Int[] selected)
  {
    rules = downgrade(rules, selected[0])
  }
}
