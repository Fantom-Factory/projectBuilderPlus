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
    podName = "pbpi"
    summary = "PBP Icons"
    version = Version([1,1,5])
    depends = ["sys 1.0","fwt 1.0","gfx 1.0"]
    srcDirs = [`fan/`]
    resDirs = [`res/img/`]
  }

}

