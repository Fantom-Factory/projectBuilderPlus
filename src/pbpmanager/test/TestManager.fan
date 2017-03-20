/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////



class TestManager : Test
{

  Void testrefresh()
  {
    Manager manager := Manager{
      repoEnv = RepoEnv{
        repoDir = Env.cur.homeDir+`resources/lib/`
        installDir = Env.cur.homeDir+`lib/`
      }
      repoConn = RepoConn{
        repoUrl = ``
      }
    }
    manager.refreshRepo
  }

  Void testDownload()
  {
    RepoEnv repoEnv := RepoEnv{
        repoDir = Env.cur.homeDir+`resources/lib/`
        installDir = Env.cur.homeDir+`lib/`
      }

    Manager manager := Manager{
      it.repoEnv = repoEnv
      repoConn = RepoConn{
        repoUrl = ``
      }
    }

    repoEnv.repoDir.listDirs.each |dir|
    {
      dir.listFiles.each|file|
      {
        manager.downloadPod(file)
      }
    }

  }


}
