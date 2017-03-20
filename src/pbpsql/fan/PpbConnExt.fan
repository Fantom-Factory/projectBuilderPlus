/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpi
using projectBuilder
using pbpcore

class PbpConnExt
{
  ProjectBuilder pbp
  SqlConnManager manager

  new make(ProjectBuilder pbp)
  {
    this.pbp = pbp
    manager = SqlConnManager(pbp)
  }

  Tab getTab()
  {
    return Tab{ text="Sql"; image=PBPIcons.sql24; manager.getGuiView(pbp.getProjectChangeWatcher), }
  }
}
