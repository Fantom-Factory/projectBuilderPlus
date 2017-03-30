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
    podName = "pbpmdbimport"
    summary = "Utility for importing MS Access db structure."
    meta = ["pbpmdbimport":"pbpmdbimport"]
    version = Version([1,0,0])
    depends = ["sys 1.0",
               "fwt 1.0",
               "gfx 1.0",
               "web 1.0",
               "concurrent 1.0",

               "pbpi 1.1+",
               "projectBuilder 1.3+",
               "pbpcore 1.2+",
               "pbpgui 1.2+",
               "pbplogging 1.0",
               "pbpobix 1.2+",
               "haystack 1.9+",
               "spui 1.2+",
               "haystack 1.0+",
               ]

    srcDirs = [`fan/`, `fan/ui/`, `fan/lint/`,
               `test/`
              ]

	javaDirs = [`java/`]

    resDirs = [`locale/`]
    meta = ["pbpMenuExt": ""]


  }

}

