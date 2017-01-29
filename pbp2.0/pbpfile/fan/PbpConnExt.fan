/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using pbpi
using projectBuilder

**
** PHP connection extension entry point. Main app will use this to bootstrap
** extension into it's UI.
**
class PbpConnExt
{
  ProjectBuilder pbp
  
  new make(ProjectBuilder pbp)
  {
    this.pbp = pbp
  }

  Tab getTab()
  {
    return Tab{ text="File"; image = PBPIcons.fileTab24 ; FileConnManager(pbp).getGuiView, }
  }
}
