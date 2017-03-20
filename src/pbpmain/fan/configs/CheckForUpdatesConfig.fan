/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore


const class CheckForUpdatesConfig : Configuration
{
  override Obj? invoke(Obj? msg, Str:Obj? options := [:])
  {
    ManagerUtil.checkForUpdates()
    return null
  }
}
