/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


** For generic untype message passing to/from pbp without introducing a dependency on pbpmain pod
** For a safer alternative to chained dynamic calls
mixin PbpListener
{
  abstract Obj? callback(Str id, Obj?[] args:=[,])

  ** get Current project
  Project? prj()
  {
    callback("getCurProject") as Project
  }

  ** get current PbpWorkspace
  Obj workspace()
  {
    callback("getWorkspace")
  }

  ** get builder
  Obj getBuilder()
  {
    callback("getBuilder")
  }

  ** get connection providers
  [Str:ConnProvider]? getConnProviders()
  {
    callback("getConnProviders") as Str:ConnProvider
  }

  abstract Bool isSiteRecordsExplorer(Obj? widget)
  abstract Bool isEquipRecordsExplorer(Obj? widget)
  abstract Bool isPointRecordsExplorer(Obj? widget)
  abstract Bool isQueryRecordsExplorer(Obj? widget)
}
