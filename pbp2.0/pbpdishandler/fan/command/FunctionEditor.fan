/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using projectBuilder

class FunctionEditor : Command
{
  private EnvHandler ehandler
  private ProjectBuilder pbp

  new make(ProjectBuilder pbp) : super.makeLocale(Pod.of(this), "functionEditor")
  {
    this.pbp = pbp
    ehandler = EnvHandler(pbp)
  }

  override Void invoked(Event? e)
  {
    EngineWindow(e.window, ehandler, pbp).open
  }
}
