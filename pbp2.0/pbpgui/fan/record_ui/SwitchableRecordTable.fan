/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore

class SwitchableRecordTable : EdgePane
{
  Str:Map recMap
  Combo tableSelector
  Table recTable := Table{multi=true}
  private RecTableModel recTableModel
  new make(Combo tableSelector, Str:Map recMap, Project currentProject)
  {
    this.recMap = recMap
    this.tableSelector = tableSelector
    tableSelector.onModify.add |event|
    {
      recTableModel.update(recMap[(event.widget as Combo).selected])
      recTable.refreshAll
    }
    top = GridPane{numCols=2; Label{text=""}, tableSelector,}

    this.recTableModel = RecTableModel([:], currentProject)
    recTable.model = recTableModel
    center = recTable
  }

  Record[] getSelectedRecs()
  {
    return recTableModel.getRows(recTable.selected)
  }

}
