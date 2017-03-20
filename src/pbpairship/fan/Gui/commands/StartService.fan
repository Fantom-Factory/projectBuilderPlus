/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using projectBuilder

class StartService : Command
{
  ProjectBuilder pbp
  new make(ProjectBuilder pbp) : super.makeLocale(Pod.of(this), "startService")
  {
    this.pbp = pbp
  }

  override Void invoked(Event? event)
  {
    Service pbpAirship := Service.find(PbpAirship#)
    pbpAirship.start()
  }

}
