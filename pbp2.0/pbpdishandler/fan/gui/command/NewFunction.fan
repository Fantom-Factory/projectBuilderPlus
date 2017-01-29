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

class NewFunction : Command
{
    private Table functionTable

  new make(Table functionTable) : super.makeLocale(Pod.of(this), "NewFunction")
  {
    this.functionTable = functionTable
  }

  override Void invoked(Event? e)
  {
    FunctionWindow(e.window).open

    model := functionTable.model as FunctionTableModel
    model.update()
    functionTable.refreshAll

    functionTable.selected = [functionTable.model.numRows-1]
    functionTable.onSelect.fire(Event() {widget = functionTable})
  }
}
