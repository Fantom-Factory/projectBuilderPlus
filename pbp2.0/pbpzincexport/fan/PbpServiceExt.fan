/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using projectBuilder
using pbpcore
using pbpgui
using concurrent
using pbpi

class PbpServiceExt
{
  ProjectBuilder pbp
  new make(ProjectBuilder pbp)
  {
    this.pbp = pbp

    popupItems := pbp.auxWidgets["addRecTreePopupItems"]

    if(pbp.auxWidgets["addRecTreePopupItems"] == null)
        pbp.auxWidgets["addRecTreePopupItems"] = MenuItemWrapper[,]

    cmd := ExportToZincCommand(pbp)
    (pbp.auxWidgets["addRecTreePopupItems"] as List).add(ExportItemWrapper(cmd,cmd.name))
  }

  MenuItem[] getMenuItems()
  {
    MenuItem[] menuItems := [,]
    return menuItems
  }
}
