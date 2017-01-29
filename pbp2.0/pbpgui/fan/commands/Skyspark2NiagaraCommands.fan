/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


using fwt
using gfx
using pbpcore

**
** Skyspark2NiagaraCommands
**
class Skyspark2NiagaraCommand : Command
{
  private PbpListener pbp
  new make(PbpListener pbp) : super.makeLocale(Pod.find("projectBuilder"), "skyspark2niagara")
  {
    this.pbp = pbp
  }

  override Void invoked(Event? e)
  {
    prj := pbp.prj
    Builder builder := pbp.getBuilder
    prov := pbp.getConnProviders["ObixConnProvider"]
    prov?->skyspark2Niagara(prj, e)
  }
}

