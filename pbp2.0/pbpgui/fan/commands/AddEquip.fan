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
abstract class AbstractAddEquip : Command
{
    protected PbpListener pbp

    new make(PbpListener pbp) : super.makeLocale(Pod.find("projectBuilder"), "addEquip")
    {
        this.pbp = pbp
    }

    protected abstract Record[] getSelectedRecords(Event? e)

    protected abstract Void afterInvoked(Event? e)

    override Void invoked(Event? e)
    {
        prj := pbp.prj
        PbpWorkspace ws := pbp.workspace

        selected := getSelectedRecords(e)
        if (selected.size > 0)
        {
            prj.add(RecordFactory.getEquip(selected.first))
        }
        else
        {
            prj.add(RecordFactory.getEquip())
        }

        afterInvoked(e)
    }
}

//TODO: Send record to an observer.
class AddEquip : AbstractAddEquip
{
    new make(PbpListener pbp) : super.make(pbp) { }

    protected override Record[] getSelectedRecords(Event? e)
    {
        prj := pbp.prj
        PbpWorkspace ws := pbp.workspace
        siteRecordExplorer := ws.siteExplorer as RecordExplorer ?: throw Err("Invalid state. ws.siteExplorer is not RecordExplorer") // parent

        return siteRecordExplorer.getSelected
    }

    protected override Void afterInvoked(Event? e)
    {
        prj := pbp.prj
        PbpWorkspace ws := pbp.workspace
        equipRecordExplorer := ws.equipExplorer as RecordExplorer ?: throw Err("Invalid state. ws.equipExplorer is not RecordExplorer") // target
        equipRecordExplorer.update(prj.database.getClassMap(Equip#))
        equipRecordExplorer.refreshAll
    }
}

