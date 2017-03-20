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

abstract class AbstractAddPoint : Command
{
    protected PbpListener pbp

    new make(PbpListener pbp) : super.makeLocale(Pod.find("projectBuilder"), "addPoint")
    {
        this.pbp = pbp
    }

    protected abstract Record[] getSelectedRecords(Event? e)

    protected abstract Void afterInvoked(Event? e)

    override Void invoked(Event? e)
    {
        prj := pbp.prj
        PbpWorkspace ws := pbp.workspace

        Record? rectoadd := null

        selected := getSelectedRecords(e)
        if (selected.size > 0)
        {
            Equip parentEq := selected.first
            Site? parentSite := prj.database.getById(parentEq.get("siteRef").val.toStr)
            prj.add(RecordFactory.getPoint(parentSite,parentEq))
        }
        else
        {
            prj.add(RecordFactory.getPoint())
        }

        afterInvoked(e)
    }
}

//TODO: Send record to an observer.
class AddPoint : AbstractAddPoint
{
    new make(PbpListener pbp) : super.make(pbp) { }

    protected override Record[] getSelectedRecords(Event? e)
    {
        prj := pbp.prj
        PbpWorkspace ws := pbp.workspace
        equipRecordExplorer := ws.equipExplorer as RecordExplorer ?: throw Err("Invalid state. ws.equipExplorer is not RecordExplorer") // parent

        return equipRecordExplorer.getSelected
    }

    protected override Void afterInvoked(Event? e)
    {
        prj := pbp.prj
        PbpWorkspace ws := pbp.workspace
        pointRecordExplorer := ws.pointExplorer as RecordExplorer ?: throw Err("Invalid state. ws.pointExplorer is not RecordExplorer") // target
        pointRecordExplorer.update(prj.database.getClassMap(pbpcore::Point#))
        pointRecordExplorer.refreshAll
    }

}
