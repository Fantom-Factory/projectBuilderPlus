/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore
using pbpi
using pbplogging

class ChangesetWindow : PbpWindow
{
  File changesetfile
  EdgePane mainWrapper := EdgePane{}

  new make(Window parentWindow, File changesetfile):super(parentWindow)
  {
    this.changesetfile = changesetfile
  }

  override Obj? open()
  {
    icon = PBPIcons.pbpIcon16
    title="Changeset for ${changesetfile.basename}"
    mainWrapper.center = Table{
      model=ChangeTableModel(changesetfile.readObj)
    }
    mainWrapper.bottom = ButtonGrid{
      Button(Dialog.ok()),
    }
    content = mainWrapper
    super.open()
    return null
  }
}

class ChangeTableModel : TableModel
{
  const Str ID := "id"
  const Str TS := "ts"
  const Str ADDDATA := "Additional Data"
  const Str TARGET := "target"
  Change[] rows
  Str[] cols := [ID, TS, TARGET, ADDDATA]
  override Int numRows()
  {
    return rows.size
  }
  override Int numCols()
  {
    return cols.size
  }
  new make(List changes)
  {
    this.rows = changes
  }
  override Str text(Int col, Int row)
  {
    switch(header(col))
    {
      case TS:
        return rows[row].ts.toStr
      case ID:
        return rows[row].id.toStr
      case TARGET:
        return rows[row].target.toStr
      case ADDDATA:
        return rows[row].opts.toStr
      default:
      return ""
    }
  }
  override Str header(Int col)
  {
    return cols[col]
  }


}
