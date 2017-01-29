/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using projectBuilder

class EnvHandler
{
  private ProjectBuilder pbp
  File localEnv := Env.cur.homeDir + `etc/pbpdishandler/` { private set }

  new make(ProjectBuilder pbp)
  {
    this.pbp = pbp
    localEnv.createDir("standard")
  }

  File makenewfolder(Str name)
  {
    return localEnv.createDir(name)
  }

  File getFolder(Str name)
  {
    return localEnv + name.toUri + `/`
  }


}
