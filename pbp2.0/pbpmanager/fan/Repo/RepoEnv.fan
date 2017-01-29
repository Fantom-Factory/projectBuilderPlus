/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////



class RepoEnv
{
  File repoDir
  File installDir

  new make(|This| f)
  {
    f(this)
  }

  File getPodDir(Str programname)
  {
    if(isPodDirInRepo(programname) == false)
    {
      return repoDir.createDir(programname)
    }
    else
    {
      return repoDir+`${programname}/`
    }
  }

  Bool isPodDirInRepo(Str programname)
  {
    return File(repoDir.uri+programname.toUri+`/`).exists
  }

  Bool isPodInstalled(Str programname, Str version)
  {
    Pod? installed := Pod.find(programname.split('-')[0], false)
    if(installed == null) {return false}
    else if(installed.version < Version.fromStr(version)){return false}
    else {return true}
  }
}
