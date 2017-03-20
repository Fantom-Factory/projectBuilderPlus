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
    podName = "pbptools"
    meta    = ["pbpserviceext":"pbpserviceext"]
    summary = "PBP Tools"
    version = Version([1,2,1])
    depends = ["sys 1.0+",
               "fwt 1.0+",
               "gfx 1.0+",
               "pbpgui 1.0+",
               "pbpcore 1.0+",
               "pbpquery 1.0+",
               "projectBuilder 1.0+"
              ]

    srcDirs = [`fan/`,
               `fan/increment/`,
               `fan/mapping/`
              ]
    resDirs = [`locale/`,
               `res/`,
               `res/img/`
              ]
    meta    = ["pbpToolbarExt": ""]

  }

}

