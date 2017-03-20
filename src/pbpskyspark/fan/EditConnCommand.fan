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

class EditConnCommand : Command
{
  private SkysparkConnManager connManager
  private ProjectBuilder pbp

  new make(SkysparkConnManager connManager, ProjectBuilder pbp) : super.makeLocale(Pod.of(this), "editConnCommand")
  {
    this.pbp = pbp
    this.connManager = connManager

  }

  override Void invoked(Event? e)
  {
    selected := connManager.getSelected

    SkysparkConn? conn := SkysparkLoginPrompt(pbp, selected.first, e.window).open
    if(conn!=null)
    {
      conn.projectName = pbp.currentProject.name
      conn.save
      connManager.update
      connManager.refreshAll
    }
  }

}
