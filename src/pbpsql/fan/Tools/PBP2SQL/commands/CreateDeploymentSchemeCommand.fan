/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using concurrent

class CreateDeploymentSchemeCommand : Command
{
  SqlConnWrapper conn
  new make(SqlConnWrapper conn):super.makeLocale(Pod.of(this), "deploySchemeSqlPackage")
  {
    this.conn = conn
  }

  override Void invoked(Event? e)
  {
     SqlPackage[] sqlPacks := (SqlPackageSelector(e.window).open() as File).readObj()
     ActorPool newPool := ActorPool()
     SqlPackageTestAreaWindow window := SqlPackageTestAreaWindow(e.window, sqlPacks, conn.worker.rowVals, conn.worker.querVal)
     SqlPackageTestAreaWindowUpdater(window, conn.worker.watcherRows, newPool).send(null)
     SqlPackageDeploymentScheme? scheme := window.open()
     if(scheme==null){return}
     Str? schemeName := Dialog.openPromptStr(e.window,"What would you like to name this scheme?")
     if (schemeName != null)
     {
         File schemeFile := (Env.cur.homeDir+`resources/sql/`).createFile(schemeName+".sqlscheme")
         schemeFile.writeObj(scheme)
     }
  }
}
