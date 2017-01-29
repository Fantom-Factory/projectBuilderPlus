/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using projectBuilder
using pbpgui
using pbpi
using pbpcore

class PbpConnExt : ConnProvider
{
  override Str name := "ObixConnProvider"

  ProjectBuilder pbp
  ObixConnManager manager

  new make(ProjectBuilder pbp)
  {
    this.pbp = pbp
    manager = ObixConnManager(pbp)
  }

  Tab getTab()
  {
    UiUpdater(manager.obixTable, pbp.getProjectChangeWatcher).send("start")
    return Tab{ text="Obix"; image=PBPIcons.obix24; manager.getGuiView, }
  }

  override Conn[] conns()
  {
    return [,]//manager.connections.vals
  }

  ** Map Skyspark(Obix) items into proper Niagara fields
  ** does not make any chnages to the project but updates obix
  Void skyspark2Niagara(Project? prj, Event e)
  {
    PbpObixConn? conn
    if(prj != null)
    {
      index := manager.obixTable.selected.first
      if(index != null)
        conn = (manager.obixTable.model as ObixTableModel).getConnection(index)
    }
    if(prj == null || conn == null || conn.lobby == null)
    {
      Dialog.openWarn(null, "No Obix connection selected and connected, please select one.")
      return
    }
    ObixToNiagara(e).doMapping(prj, conn)
  }
}
