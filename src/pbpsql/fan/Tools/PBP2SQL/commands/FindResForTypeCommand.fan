/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore
using pbplogging

class FindResForTypeCommand : Command
{

  new make() : super.makeLocale(Pod.of(this), "findResCommand")
  {
  }

  **
  ** This class must be maintained for new types, consider refactor somehow later...
  **
  override Void invoked(Event? e)
  {
    SqlProcessorSelector procSelector := e.window
    Type focus := (procSelector.sqlProcTable.model as SqlProcessorTableModel).getRow(procSelector.sqlProcTable.selected.first)
    List? files := [,]
    switch(focus)
    {
      case SqlTemplateTypeProcessor#:
        files = FileUtil.templateDir.listFiles.findAll |File f -> Bool|{return f.ext=="ttype"}
      case SqlImportHistoryProcessor#:
        files = [,]
    }
    Logger.log.debug(files.toStr)
    if(files!=null)
    {
      (procSelector.sqlResTable.model as SqlResTableModel).update(files)
      procSelector.sqlResTable.refreshAll
    }
  }


}
