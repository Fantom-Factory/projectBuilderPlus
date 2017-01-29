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

class EditFunction : Command
{
  private Table functionTable

  new make(Table functionTable) : super.makeLocale(Pod.of(this), "EditFunction")
  {
    this.functionTable = functionTable
  }

  override Void invoked(Event? e)
  {
    model := functionTable.model as FunctionTableModel

    FunctionWindow(e.window, model.getRows(functionTable.selected).first).open()
    model.update()

    sel := functionTable.selected
    functionTable.refreshAll
    functionTable.selected = sel
    functionTable.onSelect.fire(Event() {widget = functionTable})
  }
}
