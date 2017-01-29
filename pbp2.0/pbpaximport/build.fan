/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

#!/usr/bin/env fan

class Build : build::BuildPod
{
  new make()
  {
    podName = "pbpaximport"
    summary = "This utility is for importing db structure from Niagara AX."
    meta = ["pbpaximport":"pbpaximport"]
    version = Version([1,2,3])
    depends = ["sys 1.0",
               "fwt 1.0",
               "gfx 1.0",
               "pbpi 1.0+",
               "concurrent 1.0",
               "projectBuilder 1.0+",
               "pbpcore 1.0+",
               "pbpgui 1.0+",
               "pbplogging 1.0",
               "pbpobix 1.0+",
               "pbpnhaystack 1.0+",
               "haystack 1.0+",
               "xml 1.0",
               "spui 1.0+",
               "web 1.0",
               ]

    srcDirs = [`fan/`, `fan/ui/`, `fan/lint/`,
               `test/`
              ]
    resDirs = [`locale/`]
    meta = ["pbpMenuExt": ""]


  }

}

