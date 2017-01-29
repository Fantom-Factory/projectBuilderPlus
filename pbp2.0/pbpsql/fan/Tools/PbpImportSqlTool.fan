/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using sql
using pbpcore
using pbpgui
using projectBuilder

class PbpImportSqlTool : SqlTool{

  override Str name := "SQL to PBP Importer"
  override Void run()
  {

  }

  override Void open(Obj? edata, Window? parentw)
  {
    Window mainwindow := guiTemplate(parentw,Size(800,800),InsetPane())
    mainwindow.open
  }
}
