/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore
using fwt
using gfx

**
** This is just a convience class to map the gui stuff into variable names.
**
** Thibaut: moved to pbpGui so not to have circular dependencies issues and having to use dynamic call hacks
**
** This could/should probably be a const class
class PbpWorkspace
{
  ProjectExplorer? projExplorer
  RecordExplorer? siteExplorer
  RecordExplorer? equipExplorer
  RecordExplorer? pointExplorer
  TagExplorer? customTagExplorer
  TagExplorer? standardTagExplorer
  TemplateExplorer? templateExplorer
  TemplateExplorer? templateTypeExplorer

  //Indexer indexer

  new make(Str:Obj? coreWidgets, Str projHandle, Str siteHandle,  Str equipHandle,
    Str pointHandle, Str standardHandle, Str customHandle, Str templateExpHandle, Str templateTypeHandle)
  {
    //indexer = pbp.indexer
    projExplorer = coreWidgets[projHandle]
    siteExplorer = coreWidgets[siteHandle]
    equipExplorer = coreWidgets[equipHandle]
    pointExplorer = coreWidgets[pointHandle]
    templateExplorer = coreWidgets[templateExpHandle]
    standardTagExplorer = coreWidgets[standardHandle]
    customTagExplorer = coreWidgets[customHandle]
    templateTypeExplorer = coreWidgets[templateTypeHandle]

  }

}
