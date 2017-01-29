/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using concurrent
using pbpcore

class SqlHistoryImportCommand : Command
{
  SqlConnWrapper conn
  new make(SqlConnWrapper conn):super.makeLocale(Pod.of(this), "sqlHistoryImport")
  {
    this.conn = conn
  }

  override Void invoked(Event? e)
  {
    ActorPool newPool := ActorPool()
    SqlImportHistoryProcessor? processor := SqlImportHistoryProcessor()

    AtomicRef listRef := conn.worker.colVals
    AtomicRef tableRef := conn.worker.rowVals

    Watcher watcherRows := conn.worker.watcherRows
    Watcher watcherCols := conn.worker.watcherCols

    SqlPackageEditPane[] panes := processor.getEditPanes(listRef)

    SqlPackageEditPaneUpdater(panes, watcherCols, newPool).send(null)

    SqlPackageEditor(e.window, panes){
      mainWrapper.top = ToolBar{ Button(SaveSqlPackage(panes, processor)), Button(TestSqlPackage(panes, processor, conn)),}
    }.open()
  }

}
