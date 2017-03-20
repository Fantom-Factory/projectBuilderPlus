/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////



class TestRepoWindow : Test
{
  Void testRepoWindow()
  {
    RepoEnv repoEnv := RepoEnv{
        repoDir = Env.cur.homeDir+`resources/lib/`
        installDir = Env.cur.homeDir+`lib/fan/`
      }
   RepoWindow(null){
     repoTableModel = ProgramTableModel(repoEnv)
     }.open
  }

}
