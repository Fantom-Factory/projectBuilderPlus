/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using projectBuilder

class AddConnCommand : Command
{
  private SkysparkConnManager connManager
  private ProjectBuilder pbp

  new make(SkysparkConnManager connManager, ProjectBuilder pbp) : super.makeLocale(Pod.of(this), "addConn")
  {
    this.pbp = pbp
    this.connManager = connManager
  }

  override Void invoked(Event? e)
  {
    if(pbp.currentProject != null)
    {
    SkysparkConn? conn := SkysparkLoginPrompt(pbp, null,e.window).open
      if(conn!=null)
      {
        conn.projectName = pbp.currentProject.name
        //TODO: Check if it exists here
        conn.save
        connManager.connPool.addConn(conn)
        (e.widget.parent.parent as SkysparkConnManager).refreshAll
      }
    }
    else
    {
      Dialog.openInfo(e.window,"No project selected, please select a project.")
    }
  }

}
