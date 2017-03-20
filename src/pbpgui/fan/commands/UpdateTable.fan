/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

class UpdateRecordTable : Command
{
  private Table table
  private Map map
  new make(Table table, Map map) : super.makeLocale(Pod.find("projectBuilder"),"refreshTable")
  {
    this.table = table
    this.map = map
  }

  override Void invoked(Event? e)
  {
    (table.model as RecTableModel).update(map)
    //tree.refreshNode(tree.model->tree->latestNode)
    table.refreshAll
  }

}

