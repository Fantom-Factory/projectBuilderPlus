/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using projectBuilder

class OpenAirshipWindow : Command
{
  ProjectBuilder pbp
  new make(ProjectBuilder pbp) : super.makeLocale(Pod.of(this), "openAirshipWindow")
  {
    this.pbp = pbp
  }

  override Void invoked(Event? event)
  {
    PbpAirshipWindow(event.window, ["projectBuilder":pbp], pbp.licenseInfo).open
  }

}
