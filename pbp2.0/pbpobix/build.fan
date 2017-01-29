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
    podName = "pbpobix"
    meta = ["pbpconnext":"pbpconnext"]
    summary = "This is pbp obix conn ext."
    version = Version([1,2,1])
    depends = ["sys 1.0",
               "fwt 1.0",
               "gfx 1.0",
               "pbpi 1.0+",
               "concurrent 1.0",
               "haystack 1.0+",
               "xml 1.0",
               "spui 1.0+",
               "projectBuilder 1.0+",
               "pbpcore 1.0+",
               "pbpgui 1.0+",
               "obix 1.0+",
               "web 1.0+",
               "pbplogging 1.0+",
               "pbpskyspark 1.0+"
               ]
    resDirs = [`locale/`]
    srcDirs = [`fan/`,
               `fan/commands/`,
               `fan/obixmapper/`
               ]


  }

}

