/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpmanager
using fwt
using gfx
using pbplogging

class ManagerUtil : Logging
{
  //Run this in a thread
  static Void checkForUpdates()
  {
    ManagerUtil().info("Checking for Updates")
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
    manager.refreshRepoAt("*")
    File[] podDir := repoEnv.repoDir.listDirs
    updateMap := Str:Bool[:]
    podDir.each |dir|
    {
      Version:File babyVersions := [:]
      Version:File podVersions := [:]
      dir.listFiles.each |file|
      {
        if(file.ext=="baby")
        {
          Version version := Version.fromStr(file.basename.split('-')[1])
          babyVersions.add(version,file)
        }
        if(file.ext=="pod")
        {
          Version version := Version.fromStr(file.basename.split('-')[1])
          podVersions.add(version,file)
        }
      }
      Version maxversion := [podVersions.keys.max, babyVersions.keys.max].max
      //echo(maxversion)
      //echo(repoEnv.isPodInstalled(podVersions[maxversion].basename, maxversion.toStr))
      //echo(podVersions[maxversion].basename)
      updateMap.add(dir.basename, !repoEnv.isPodInstalled(podVersions[maxversion].basename, maxversion.toStr))
    }
    if(updateMap.vals.find |Bool b->Bool| {return b})
    {
       ManagerUtil().info("Updates Available")
       //echo(updateMap.findAll |Bool updateStat, Str name -> Bool| {return updateStat}.keys)
       //Update here, should be changed to refreshing MenuItem? I think that would work... should put menuitem's in seperate classes.
       Main.updatesAvail.getAndSet(true)
       Main.updateMap.getAndSet(updateMap.toImmutable)
       Main.helpMenuWatcher.set
    }
  }

}
