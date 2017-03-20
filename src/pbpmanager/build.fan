/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

class Build : build::BuildPod
{
  new make()
  {
    podName = "pbpmanager"
    summary = "This is a pbp manager and updater"
    version = Version([1,1,8])
    depends = ["sys 1.0",
               "fwt 1.0",
               "gfx 1.0",
               "concurrent 1.0",
               "pbpgui 1.1.5+",
               "pbpcore 1.1.5+",
               "fanr 1.0",
               "web 1.0",
               "util 1.0",
               "spui 1.1.5+",
               "pbplogging 1.0"
               ]

    resDirs = [`locale/`]

    srcDirs = [`fan/`,
               `fan/Frontend/`,
               `fan/Manager/`,
               `fan/Program/`,
               `fan/Repo/`,
               `test/`
               ]


  }

}

