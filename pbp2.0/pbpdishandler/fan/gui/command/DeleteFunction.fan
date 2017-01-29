/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using projectBuilder
using pbpcore
using concurrent
using pbpgui

class DeleteFunction : Command
{
    private Table functionTable

  new make(Table functionTable) : super.makeLocale(Pod.of(this), "deleteFunction")
  {
    this.functionTable = functionTable
  }

  override Void invoked(Event? e)
  {
    model := functionTable.model as FunctionTableModel

    DisFunc? func := model.getRows(functionTable.selected).first
    if(func != null)
    {
      File folder := model.folder
      folder.plus(`${func.displayName}.dfunc`).delete
      model.update()
      functionTable.refreshAll
      functionTable.onSelect.fire(Event() {widget = functionTable})
    }
  }

}
