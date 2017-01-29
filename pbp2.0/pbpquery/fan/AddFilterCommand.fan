/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore
using fwt
using pbpgui

class AddFilterCommand : Command
{
  private PbpListener pbp
  private Bool isNot := false

  new make(PbpListener pbp, Bool isNot := false) : super()
  {
    this.isNot = isNot
    this.pbp = pbp
  }

  override Void invoked(Event? event)
  {
    Map auxWidgets := pbp.callback("getAuxWidgets")
    if(auxWidgets.containsKey("latestwb")){
      SearcherPane searcherpane := auxWidgets["latestwb"]
      table := event.widget as Table ?: throw Err("Widget is not Table but ${event.widget?.typeof}")
      model := table.model as TagTableModel ?: throw Err("Model is not TagTableModel but ${table.model.typeof}")
      Tag[] tags := model.getRows(table.selected)
      filter := ""
      tags.each |tag|
      {
        if( ! filter.isEmpty )
          filter += " OR "
        filter += tag.name.toStr
      }
      searcherpane.addFilter(filter, isNot)
    }
  }
}
