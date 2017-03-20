/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore
using pbpgui
using projectBuilder

class NewSender : Command
{
  ProjectBuilder pbp
  new make(ProjectBuilder pbp) : super.makeLocale(Pod.of(this), "newSender")
  {
    this.pbp = pbp
  }

  override Void invoked(Event? event)
  {
    File targetProject := (ProjectSelector(event.window, pbp).open as File[]).first
    SqlToSkysparkSender? sender := SqlToSkysparkSenderWindow(event.window, Project(targetProject.basename)).open
    if(sender == null){return}
    File senderFile := (Env.cur.homeDir+`etc/pbpairship/`).createFile(sender.options["name"].toStr+".sender")
    senderFile.writeObj(sender)
    ((event.window as PbpAirshipWindow).senderTable.model as SenderTableModel).update
    (event.window as PbpAirshipWindow).senderTable.refreshAll
    return
  }
}
