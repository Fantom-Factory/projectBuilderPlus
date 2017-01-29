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
        podName = "pbpexport"
        summary = "This is pbp local file conn ext."
        version = Version([1,0,1])
        depends = ["sys 1.0",
                   "fwt 1.0",
                   "gfx 1.0",
                   "pbpi 1.0+",
                   "projectBuilder 1.0+",
                   "pbpcore 1.0+",
                   "pbpgui 1.0+"]
        srcDirs = [`fan/`]
        resDirs = [`locale/`]
        meta = ["pbpMenuExt": ""]
  }

  private static Str makeMenuExtMeta(Str:Type[] menuExtConfig)
  {
    return StrBuf().out.writeObj(menuExtConfig).toStr
  }
}

