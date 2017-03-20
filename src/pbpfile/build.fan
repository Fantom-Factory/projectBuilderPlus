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
    podName = "pbpfile"
    meta = ["pbpconnext":"pbpconnext"]
    summary = "This is pbp local file conn ext."
    version = Version([1,0,1])
    depends = ["sys 1.0",
               "fwt 1.0",
               "gfx 1.0",
               "pbpi 1.1",
               //"concurrent 1.0",
               //"haystack 1.0",
               //"xml 1.0",
               //"spui 1.0",
               "projectBuilder 1.3+",
               "pbpcore 1.2",
               "pbpgui 1.2"
               ]

    srcDirs = [`fan/`
               ]

   resDirs=[`locale/`]


  }
}

