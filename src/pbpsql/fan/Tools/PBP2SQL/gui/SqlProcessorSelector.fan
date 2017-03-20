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
using pbpi


class SqlProcessorSelector : PbpWindow
{
  Table sqlProcTable
  Table sqlResTable
  EdgePane mainWrapper := EdgePane{}
  SashPane innerWrapper := SashPane{}

  new make(Window? parent) : super(parent)
  {
    sqlProcTable = Table{model=SqlProcessorTableModel()}
    sqlResTable  = Table{model=SqlResTableModel()}
    sqlProcTable.onSelect.add |e| {
      FindResForTypeCommand().invoked(e)
    }
  }

  override Obj? open()
  {
    icon = PBPIcons.pbpIcon16
    innerWrapper.add(sqlProcTable)
    innerWrapper.add(sqlResTable)
    innerWrapper.weights = [50,50]
    mainWrapper.center = innerWrapper
    mainWrapper.bottom = ButtonGrid{numCols=1; Button{text="Next"; onAction.add|e|{e.window.close}},}
    content = mainWrapper
    super.open()
    Type targettype := (sqlProcTable.model as SqlProcessorTableModel).getRow(sqlProcTable.selected.first)
    Obj? toreturn := null
    if(targettype.name != SqlImportHistoryProcessor#.name)
    {
      toreturn = targettype.make([(sqlResTable.model as SqlResTableModel).getRow(sqlResTable.selected.first).readObj])
    }
    else
    {
      toreturn = targettype.make()
    }
    return toreturn
  }
}

class SqlProcessorTableModel : TableModel
{
  Type[] rows
  Str[] cols := ["Name", "Type"]
  new make()
  {
    rows = Pod.of(this).types.findAll |Type type -> Bool|{return type.inheritance.contains(SqlProcessor#)}
  }
  Type getRow(Int row)
  {
    return rows[row]
  }
  override Str header(Int col){return cols[col]}
  override Int numCols(){return cols.size}
  override Int numRows(){return rows.size}
  override Str text(Int col, Int row)
  {
    switch(col)
    {
      case 0:
        return rows[row].name
      case 1:
        return "hi"//rows[row].field("focus").get
      default:
        return ""
    }
  }
}

class SqlResTableModel : TableModel
{
  File[] rows := [,]
  Str[] cols := ["Name"]
  new make()
  {

  }

  Void update(File[] newrows)
  {
    rows = newrows
  }

  File getRow(Int row)
  {
    return rows[row]
  }
  override Str header(Int col){return cols[col]}
  override Int numCols(){return cols.size}
  override Int numRows(){return rows.size}
  override Str text(Int col, Int row)
  {
    return rows[row].basename
  }
}
