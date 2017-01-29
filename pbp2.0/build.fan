/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

#! /usr/bin/env fan

using build

**
** buildall.fan
**
** This is the second sub-script of the two part buildall script.
** Once buildboot has completed this development environment now has
** the necessary infrastructure to self build the rest of the pod
** library.
**
class Build : BuildGroup
{

  new make()
  {
    childrenScripts =
    [
    `pbplogging/build.fan`,
    `pbpicons/build.fan`,
    `lucene/build.fan`,
    `pbpcore/build.fan`,
    `pbpgui/build.fan`,
    `kayako/build.fan`,
    `specialui/build.fan`,
    `pbpmanager/build.fan`,
    `pbpmain/build.fan`,
    `pbpskyspark/build.fan`,
    `pbpquery/build.fan`,
    `pbpsql/build.fan`,
    `pbpdishandler/build.fan`,
    //`pbpfile/build.fan`, //uncomment when ready
    `pbpobix/build.fan`,
    `pbpairship/build.fan`,
    `pbpexport/build.fan`,
    `pbptools/build.fan`,
    `pbpnhaystack/build.fan`,
    `pbpaximport/build.fan`,
    `pbpmdbimport/build.fan`,
    `pbpzincexport/build.fan`,
    `pbptagging/build.fan`,
    ]
  }

}
