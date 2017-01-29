/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore
using pbpgui

class SqlPackageSelector : PbpWindow
{
  EdgePane mainWrapper := EdgePane{}
  Table pckTable := Table{model=SqlPackageTableModel(SqlPackageUtil.getPackageDir)}
  Bool cont := false
  new make(Window? parentWindow) : super(parentWindow)
  {
  }

  override Obj? open()
  {
    title = "Select Sql Package"
    mainWrapper.center= pckTable
    mainWrapper.bottom= ButtonGrid{numCols=2; Button{text="Next"; onAction.add|e|{cont=true; e.window.close}}, Button(Dialog.cancel),}
    content=mainWrapper
    super.open()
    if(cont)
    {
      return (pckTable.model as SqlPackageTableModel).getRows(pckTable.selected).first
    }
    return null
  }


}
class SqlPackageTableModel : TableModel
{
  File packageDir
  File[] rows := [,]
  Str[] cols := [,]
  new make(File packageDir)
  {
    this.packageDir = packageDir
    rows = packageDir.listFiles.findAll|File f->Bool| {return f.ext == "sqlpack"}
    cols = ["Name"]
  }
  Void update()
  {
    rows = packageDir.listFiles.findAll|File f->Bool| {return f.ext == "sqlpack"}
  }

  File[] getRows(Int[] selected)
  {
    toreturn := [,]
    selected.each |index|
    {
      toreturn.push(rows[index])
    }
    return toreturn
  }

  override Int numCols(){return cols.size}
  override Int numRows(){return rows.size}
  override Str text(Int col, Int row)
  {
    return rows[row].basename
  }
  override Str header(Int col)
  {
    return cols[col]
  }
}
