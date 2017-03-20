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
    podName = "pbpgui"
    summary = "These are for the gui for pbp"
    version = Version([1,2,1])
    depends = ["sys 1.0",
               "pbpcore 1.1.5+",
               "pbpi 1.1.5+",
               "haystack 1.0+",
               "concurrent 1.0",
               "util 1.0",
               "fwt 1.0",
               "gfx 1.0",
               "pbplogging 1.0+",


                                             ]
    resDirs = [`locale/`]
    //javaDirs = [`java/`]
    srcDirs = [`fan/`,
               `fan/fields/`,
               `fan/project_ui/`,
               `fan/record_ui/`,
               `fan/tag_ui/`,
               `fan/Instruction/`,
               `fan/template/`,
               `fan/commands/`,
               `fan/util/`,
               `test/`
               ]

  }

}

