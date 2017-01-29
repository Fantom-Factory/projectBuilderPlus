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
    podName = "pbpdishandler"
    meta = ["pbpserviceext":"pbpserviceext"]
    summary = "Display Handler Service"
    version = Version([1,1,6])
    depends = ["sys 1.0+",
               "fwt 1.0+",
               "gfx 1.0+",
               "pbpgui 1.0+",
               "pbpcore 1.0+",
               "projectBuilder 1.0+",
               "spui 1.0+",
               "concurrent 1.0+"
               ]

    resDirs = [`locale/`]
    srcDirs = [`fan/`,
               `fan/core/`,
               `fan/core/rule/`,
               `fan/core/apply/`,
               `fan/command/`,
               `fan/gui/`,
               `fan/gui/command/`,
               `fan/gui/description/`,
               `test/`,
               ]

  }

}

