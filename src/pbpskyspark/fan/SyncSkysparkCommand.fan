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
using pbpgui

class SyncSkysparkCommand : Command
{
  SkysparkConnManager connManager
  ProjectBuilder pbp
  new make(SkysparkConnManager connManager, ProjectBuilder pbp) : super.makeLocale(Pod.of(this), "syncSkysparkCommand")
  {
    this.pbp = pbp
    this.connManager = connManager
  }

  override Void invoked(Event? e)
  {
    selected := connManager.getSelected

    //response := Dialog.openInfo(e.window,"You need to recompile the pbp file before you may proceed, Continue?",null,Dialog.yesNo)
    //if (response == Dialog.no) {
    //return
    //}
    
    resp := Dialog.openQuestion(e.window,
                                "Are you ready to sync this project to ${selected.size} connections?",
                                null,
                                Dialog.yesNo)

    
    if (resp == Dialog.yes)
    {
      useDisMacro := pbp.prj.projectConfigProps.get("useDisMacro", "false").toBool
      echo(useDisMacro)
      pbpgui::Save(pbp).invoked(e)

      selected.each |conn|
      {
        conn.syncConn(useDisMacro)
      }
    }
    
    PbpWorkspace pbpwrapper := pbp.asWorkspace
    pbpwrapper.siteExplorer.update(pbp.currentProject.database.getClassMap(Site#))
    pbpwrapper.equipExplorer.update(pbp.currentProject.database.getClassMap(Equip#))
    pbpwrapper.pointExplorer.update(pbp.currentProject.database.getClassMap(pbpcore::Point#))
    pbpwrapper.siteExplorer.refreshAll
    pbpwrapper.equipExplorer.refreshAll
    pbpwrapper.pointExplorer.refreshAll

  }

}
