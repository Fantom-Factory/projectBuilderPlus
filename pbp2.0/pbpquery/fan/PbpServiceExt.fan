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
    //Install Service Here
    EdgePane body := EdgePane{}
    Tab wbTab := Tab{ text="Query"; image = PBPIcons.query32; body,}
    this.pbp.builder._recordTabs.add(wbTab)
    this.pbp.builder._recordTabs.relayout
    WorkbenchUpdater(wbTab, pbp, pbp.getProjectChangeWatcher).send(null)
   if(pbp.auxWidgets["addRecTreePopupItems"] == null)
       pbp.auxWidgets["addRecTreePopupItems"] = MenuItemWrapper[,]
    (pbp.auxWidgets["addRecTreePopupItems"] as List).add(SearcherItemWrapper(GetChildrenCommand(pbp),"Get Children"))

    func := |Event e|{
      e.popup = Menu{
        MenuItem{
          text = "Add Filter"
          onAction.add |g|
          {
           AddFilterCommand(pbp).invoke(e)
          }
        },
        MenuItem{
          text = "Add NOT Filter"
          onAction.add |g|
          {
           AddFilterCommand(pbp, true).invoke(e)
          }
        },
      }
    }
    pbp.asWorkspace.standardTagExplorer.addOnTablePopup(func)
    pbp.asWorkspace.customTagExplorer.addOnTablePopup(func)
  }

  MenuItem[] getMenuItems()
  {
    MenuItem[] menuItems := [,]
    return menuItems
  }
}











