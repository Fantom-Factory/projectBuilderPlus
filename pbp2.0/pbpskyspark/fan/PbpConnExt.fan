/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using projectBuilder
using pbpi
using pbpgui
using pbpcore

class PbpConnExt : ConnProvider
{
  override Str name := "SkysparkConnProvider"

  ProjectBuilder pbp
  SkysparkConnManager connManager

  new make(ProjectBuilder pbp)
  {
    this.pbp = pbp
    connManager = SkysparkConnManager(this.pbp)
  }

  Tab getTab()
  {
    UiUpdater(connManager, pbp.getProjectChangeWatcher).send("start")
    return Tab{ text="Skyspark"; image=PBPIcons.skyspark24; connManager, }
  }

  override Conn[] conns()
  {
    connManager.connPool.conns
  }
}
