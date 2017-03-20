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
    podName = "pbpairship"
    meta = ["pbpserviceext":"pbpserviceext"]
    summary = "This is pbp airship implementation."
    version = Version([1,2,0])
    depends = ["sys 1.0",
               "airship 1.0",
               "pbpsql 1.0+",
               "pbpskyspark 1.0+",
               "pbpcore 1.0+",
               "pbpgui 1.0+",
               "pbplogging 1.0+",
               "projectBuilder 1.0+",
               "fwt 1.0",
               "gfx 1.0",
               "haystack 1.0+",
               "concurrent 1.0"
              ]
    resDirs = [`locale/`]
    srcDirs = [`fan/`,
               `fan/Receiver/`,
               `fan/Sender/`,
               `fan/Sender/Interfaces/`,
               `fan/Gui/`,
               `fan/Gui/Sql/`,
               `fan/Gui/commands/`,
               `test/`
               ]


  }

}

