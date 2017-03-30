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
    podName = "projectBuilder"
    summary = "This utility is a project builder."
    version = Version([1,3,9,1])
    meta = ["pbp.name":"Project Builder Plus"]
    depends = ["sys 1.0+",
               "pbpcore 1.2+",
               "pbpgui 1.0+",
               "pbpmanager 1.0+",
               //"pbpairship 1.0",
               "concurrent 1.0+",
               "fwt 1.0+",
               "web 1.0+",
               "gfx 1.0+",
               "pbpi 1.0+",
               "kayako 1.0+",
               "pbplogging 1.0+",
		
               "haystack 1.9",
               ]

    srcDirs = [`fan/`,
               `fan/commands/`,
               `fan/configs/`,
               `fan/util/`,
               `fan/exts/`
               ]

    resDirs = [`locale/`]

    index = [
     "bass.licensing.server.url" : "pbplic.bassg.com",
     "bass.licensing.server.port" : "80",
     "bass.ticketing.url" : "http://www.basgraphics.com/helpdesk",
     "bass.logger.minlevel" : "debug",
    ]
  }

}

