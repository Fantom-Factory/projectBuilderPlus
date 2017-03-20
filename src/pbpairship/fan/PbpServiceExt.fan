/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using airship
using projectBuilder
using pbplogging

class PbpServiceExt : Logging
{

  ProjectBuilder pbp
  new make(ProjectBuilder pbp)
  {
    this.pbp = pbp
    //install service here...
    PbpAirship(AirshipConfig.SERVICE){

    }.install
  }

  MenuItem[] getMenuItems()
  {
    MenuItem[] menuItems := [,]
    menu := Menu{
      text = Pod.of(this).locale("aboutPbpAirship.name")
      MenuItem(StartService(pbp)),
      MenuItem(StopService(pbp)),
      MenuItem(OpenAirshipWindow(pbp)),
    }
    menuItems.add(menu)
    return menuItems
  }
}
