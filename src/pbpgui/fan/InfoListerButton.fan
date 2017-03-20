/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt

class InfoListerButton : Button {

  Str[] rowList
  Widget? updateField
  Func? actionUpdater

  new make(|This| f) : super.make() {
    f(this)
    onAction.add |Event e| {
      unitTable := Table{
        it.onAction.add |Event te| {
          table := te.widget as Table
          selectedValue := (table.model as FinderTableModel).getRow(table.selected.first)
          updateWidget := updateField as Text
          if (this.actionUpdater != null) {
            updateWidget.text = this.actionUpdater(selectedValue)
          } else {
            updateWidget.text = selectedValue
          }
          te.widget.window.close
        }
      }
      unitTableModel := FinderTableModel(rowList)
      unitTable.model = unitTableModel
      filterText := Text{
        it.onKeyDown.add |Event ke| {
          filterTextVal := (ke.widget as Text).text
          if (filterTextVal.size <= 1 || filterTextVal == "") {
            unitTableModel.resetFilter
          } else {
            unitTableModel.filter(filterTextVal)
          }
          unitTable.refreshAll
        }
      }
      newWindow := Window{
        it.size=gfx::Size(500, 500)
        title=this.text
        content=EdgePane{
          top=filterText
          center=unitTable
        }
      }
      newWindow.open()
    }
  }
}
