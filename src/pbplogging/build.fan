/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using build

**
** Build: pbplogging
**
class Build : BuildPod
{
  new make()
  {
    podName = "pbplogging"
    summary = "Cenralized logging"
    depends = ["sys 1.0+", "util 1.0+"]
    srcDirs = [`fan/`]
  }
}
