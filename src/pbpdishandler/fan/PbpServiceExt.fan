/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using fwt
using gfx
using projectBuilder
using pbpcore
using pbpgui

class PbpServiceExt
{
  private ProjectBuilder pbp

  new make(ProjectBuilder pbp)
  {
    this.pbp = pbp
    this.pbp.navNameFuncExecutor = |Event e -> Void| {
      DisFunc[] funcsList := [,]
      navNameFuncs := pbp.currentProject.projectConfigProps.get("makeNavNameFunction")

      if (navNameFuncs.size > 0) {
          navNameFuncs.split(',').each |Str func| {
            funcsList.add(func.toUri.toFile.readObj)
          }

          funcsList.each |disFunc|
          {
            disFunc.applies.each |disApply|
            {
              if (disApply is DisApplyTag) {
                (disApply as DisApplyTag).projectBuilder = this.pbp
              }
            }
          }

          DisEngine engine := DisEngine(funcsList)
          Record[] sites := engine.executeFor(Site#, pbp.currentProject.database)
          executeFunctions(sites, e, "Updating Site records..")
          Record[] equips := engine.executeFor(Equip#, pbp.currentProject.database)
          executeFunctions(equips, e, "Updating Equip records..")
          Record[] points := engine.executeFor(pbpcore::Point#, pbp.currentProject.database)
          executeFunctions(points, e, "Updating Point records")

          PbpWorkspace workspace := pbp.asWorkspace

          workspace.siteExplorer.update(pbp.currentProject.database.getClassMap(Site#))
          workspace.equipExplorer.update(pbp.currentProject.database.getClassMap(Equip#))
          workspace.pointExplorer.update(pbp.currentProject.database.getClassMap(pbpcore::Point#))

          workspace.siteExplorer.refreshAll
          workspace.equipExplorer.refreshAll
          workspace.pointExplorer.refreshAll
      }
    }
  }

  Void executeFunctions(Record[] recs, Event e, Str? msgText) {
    ActorPool newPool := ActorPool()
    ProgressWindow pwindow := ProgressWindow(e.window, newPool, msgText)
    DatabaseThread dbthread := pbp.currentProject.database.getSyncThreadSafe(recs.size, pwindow.phandler, newPool)
    
    recs.each |rec| {
      dbthread.send([DatabaseThread.SAVE, rec])
    }
    
    pwindow.open()
    newPool.stop()
    newPool.join()
    pbp.currentProject.database.unlock()
  }

  MenuItem[] getMenuItems()
  {
    MenuItem[] menuItems := [,]
    menuItems.add(MenuItem(FunctionEditor(pbp)))
    return menuItems
  }

}
