/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore
using concurrent

//TODO: Send record to an observer.
abstract class AbstractAddSite : Command
{
    protected PbpListener pbp

    new make(PbpListener pbp) : super.makeLocale(Pod.find("projectBuilder"), "addSite")
    {
        this.pbp = pbp
    }

    protected abstract Void afterInvoked(Event? e)

    override Void invoked(Event? e)
    {
        prj := pbp.prj
        PbpWorkspace ws := pbp.workspace
        prj.add(RecordFactory.getSite())

        afterInvoked(e)
    }
}

//TODO: Send record to an observer.
class AddSite : AbstractAddSite
{
    new make(PbpListener pbp) : super.make(pbp) { }

    protected override Void afterInvoked(Event? e)
    {
        prj := pbp.prj
        PbpWorkspace ws := pbp.workspace
        map := prj.database.getClassMap(Site#)
        ws.siteExplorer.update(map)
        ws.siteExplorer.refreshAll
    }
}

