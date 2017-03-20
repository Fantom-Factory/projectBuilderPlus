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
    podName = "pbpsql"
    summary = "This utility is for sql connections."
    meta = ["pbpconnext":"pbpconnext"]
    version = Version([1,2,2])
    depends = ["sys 1.0",
               "fwt 1.0",
               "gfx 1.0",
               "pbpi 1.0+",
               "concurrent 1.0",
               "projectBuilder 1.0+",
               "pbpcore 1.0+",
               "pbpgui 1.0+",
               "pbplogging 1.0",
               "haystack 1.0+",
               "xml 1.0",
               "spui 1.0+",
               "sql 1.0"
               ]

    srcDirs = [`fan/`,
               `fan/Tools/`,
               `fan/Tools/PBP2SQL/`,
               `fan/Tools/PBP2SQL/gui/`,
               `fan/Tools/PBP2SQL/specialrule/`,
               `fan/Tools/PBP2SQL/sqlpackage/`,
               `fan/Tools/PBP2SQL/commands/`
               ]
   resDirs = [`locale/`]


  }

}

