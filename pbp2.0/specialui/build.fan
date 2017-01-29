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
    podName = "spui"
    summary = "This is spui."
    version = Version([1,2,0])
    depends = ["sys 1.0",
               "gfx 1.0",
               "inet 1.0",
               "fwt 1.0",
               "web 1.0",
               "obix 1.0",
               "util 1.0",
               "xml 1.0",
               "pbpgui 1.1.5+",
               "concurrent 1.0",
               "haystack 1.0+",
               "sql 1.0"
               ]

    //javaDirs = [`java/`]
    srcDirs = [`fan/`,
               `fan/Console/`,
               ]

  }

}

