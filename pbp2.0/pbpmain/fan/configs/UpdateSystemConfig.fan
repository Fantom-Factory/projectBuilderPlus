/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore
using pbpmanager
using concurrent
using pbpgui

const class UpdateSystemConfig : Configuration
{
  override Obj? invoke(Obj? msg, Str:Obj? options := [:])
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
        password = "301wpg%9s"
        }
      }
    }
    File[] podDir := repoEnv.repoDir.listDirs
    File[] newPbpVersions := podDir.findAll |File f -> Bool| {
      return (f.listFiles.findAll |File fi -> Bool| {return fi.ext == "baby"}.size > 0)
    }
    counter := 0
    newPbpVersions.each |newversion|
    {
      toInstall := manager.downloadLatestPod(newversion)
      if(toInstall!=null)
      {
        manager.installLatestPod(toInstall)
      }
      if(options.containsKey("phandler"))
      {
        (options["phandler"] as ProgressHandler).send([++counter, newPbpVersions.size, counter.toStr + "/" + newPbpVersions.size+" "+toInstall.name])
      }
    }
    if(options.containsKey("phandler"))
    {
      (options["phandler"] as ProgressHandler).send([counter, newPbpVersions.size, "Done"])
    }
    return null
  }

}
