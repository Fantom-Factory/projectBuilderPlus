/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpmanager
using concurrent
using pbpgui
using pbpcore
using kayako

class MakeNewHelpdeskTicket : Command
{
  new make():super.makeLocale(Pod.of(this), "makeNewHelpTicket")
  {

  }

  override Void invoked(Event? e)
  {
    KayakoApi.makeTicket(e.window)
  }
}

class Update : Command
{
  new make() : super.makeLocale(Pod.of(this), "updatePbp")
  {

  }

  override Void invoked(Event? e)
  {
    ActorPool newPool := ActorPool()
    ProgressWindow pwindow := ProgressWindow(e.window, newPool)
    details := GridPane{numCols=1}
    (Main.updateMap.val as Str:Bool).findAll |Bool b -> Bool| {return b}.each |v,k|{
      details.add(Label{text="Update Found for: " +k})
    }
    if(Dialog.openQuestion(e.window, "There are updates available for Project Builder Plus, would you like to download?",details,Dialog.yesNo)==Dialog.yes)
    {
      ActorPeon(newPool){
        config=UpdateSystemConfig()
        options=["phandler":pwindow.phandler]
      }.send(null)
      pwindow.open()
      newPool.stop()
      newPool.join()
      Dialog.openInfo(e.window, "Update completed, please restart Project Builder Plus")
      Env.cur.exit
    }
  }
}
class OpenVersionControl : Command
{
  new make() : super.makeLocale(Pod.of(this), "openVersionControl")
  {
  }

  override Void invoked(Event? e)
  {
    RepoEnv repoEnv := RepoEnv{
        repoDir = Env.cur.homeDir+`resources/lib/`
        installDir = Env.cur.homeDir+`lib/fan/`
      }
    Manager manager := Manager{
      it.repoEnv = repoEnv
      repoConn = RepoConn{
        repoUrl = ``
        repoAuth = RepoAuth{
        url = ""
        user = "pbplic"
        password = ""
      }
      }
    }
    RepoWindow(e.window){
      repoTableModel = ProgramTableModel(repoEnv)
      repoToolbar = ToolBar{
        addCommand(RefreshRepo(manager))
        addCommand(DownloadPod(manager))
        addCommand(InstallPod(manager))
      }
     }.open()
  }

}
