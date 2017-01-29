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

class DownloadProjectCommand : Command
{
  private SkysparkConnManager connManager
  private ProjectBuilder pbp

  new make(SkysparkConnManager connManager, ProjectBuilder pbp) : super.makeLocale(Pod.of(this), "downloadProjectCommand")
  {
    this.pbp = pbp
    this.connManager = connManager
  }

  override Void invoked(Event? e)
  {
    selected := connManager.getSelected
    resp := Dialog.openQuestion(e.window,"Are you sure you would like to delete ${selected.size} connections?",null,Dialog.yesNo)
    if(resp == Dialog.yes)
    {
      selected.each |conn|
      {
        FileUtil.findConnFile(pbp.currentProject.homeDir, conn).delete
        connManager.connPool.deleteConn(conn)
      }
      connManager.refreshAll
    }
  }

}
