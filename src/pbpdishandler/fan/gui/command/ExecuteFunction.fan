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

class ExecuteFunction : Command
{
  private ProjectBuilder pbp
  private Table functionTable

  new make(ProjectBuilder pbp, Table functionTable) : super.makeLocale(Pod.of(this), "executeFunction")
  {
    this.pbp = pbp
    this.functionTable = functionTable
  }

  override Void invoked(Event? e)
  {
    if (pbp.currentProject == null) {
      return
    }

    model := functionTable.model as FunctionTableModel

    funcs := model.getRows(functionTable.selected)
    if (funcs.size == 0) {
      return
    }

    DisEngine engine := DisEngine(funcs)
    Record[] recs := engine.execute(pbp.currentProject.database)

    ActorPool newPool := ActorPool()
    ProgressWindow pwindow := ProgressWindow(e.window, newPool)
    DatabaseThread dbthread := pbp.currentProject.database.getSyncThreadSafe(recs.size, pwindow.phandler, newPool)
    recs.each |rec|
    {
      dbthread.send([DatabaseThread.SAVE, rec])
    }
    pwindow.open()
    newPool.stop()
    newPool.join()
    pbp.currentProject.database.unlock()
    PbpWorkspace pbpwrapper := pbp.asWorkspace

    pbpwrapper.siteExplorer.update(pbp.currentProject.database.getClassMap(Site#))
    pbpwrapper.equipExplorer.update(pbp.currentProject.database.getClassMap(Equip#))
    pbpwrapper.pointExplorer.update(pbp.currentProject.database.getClassMap(pbpcore::Point#))

    pbpwrapper.siteExplorer.refreshAll
    pbpwrapper.equipExplorer.refreshAll
    pbpwrapper.pointExplorer.refreshAll
  }

}
