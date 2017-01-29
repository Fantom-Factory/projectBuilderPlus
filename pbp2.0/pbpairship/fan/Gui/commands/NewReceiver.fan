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

class NewReceiver : Command
{
  ProjectBuilder pbp
  new make(ProjectBuilder pbp) : super.makeLocale(Pod.of(this), "newReceiver")
  {
    this.pbp = pbp
  }

  override Void invoked(Event? event)
  {
    SkySparkAirshipReceiver? receiver := SkySparkAirshipReceiver(pbp.licenseInfo)
    if(receiver == null){return}
    File receiverFile := (Env.cur.homeDir+`etc/pbpairship/`).createFile("Skyspark"+".receiver")
    receiverFile.writeObj(receiver)
    ((event.window as PbpAirshipWindow).receiverTable.model as ReceiverTableModel).update
    (event.window as PbpAirshipWindow).receiverTable.refreshAll
    return
  }
}
