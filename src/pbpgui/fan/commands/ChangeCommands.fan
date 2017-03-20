/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore

class ViewChangesetCommand : Command
{
  private PbpListener pbp
  new make(PbpListener pbp) : super.makeLocale(Pod.find("projectBuilder"), "ViewChangeset")
  {
    this.pbp = pbp
  }

  override Void invoked(Event? event)
  {
    builder := pbp.getBuilder as Builder
    Tab changeTab :=  builder._auxTabs.children.first
    Table changeTable := changeTab.children.first
    ChangesetWindow(event.window,(changeTable.model as ChangesetTableModel).getRows(changeTable.selected).first).open()
    return
  }
}
