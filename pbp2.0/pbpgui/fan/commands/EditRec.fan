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

abstract class AbstractEditRec : Command
{
    protected PbpListener pbp

    new make(PbpListener pbp) : super.makeLocale(Pod.find("projectBuilder"), "editRec")
    {
        this.pbp = pbp
    }

    protected abstract Record[] getRecords(Event? e)

    protected abstract Void afterEdit(Event? e, Record[] records)

    override Void invoked(Event? e)
    {
        prj := pbp.prj

        Record[] rec := getRecords(e)
        if (rec.size-1 > 0)
        {
            List response := MultiRecordEditor(prj, rec, e.window).open

            if (response[0])
            {
                afterEdit(e, rec)
            }
        }
        else if (rec.size > 0)
        {
            List response:=RecordEditor(prj,rec[0], e.window).open

            if (response[0])
            {
                afterEdit(e, rec)
            }
        }
    }
}


class EditRec : AbstractEditRec
{
    new make(PbpListener pbp) : super.make(pbp) { }

    private static RecordExplorer recordExplorer(Event? e)
    {
        return GuiUtil.getTargetParent(e.widget, RecordExplorer#) as RecordExplorer ?: throw Err("Invalid state. e.widget(.parent)+ is not RecordExplorer")
    }

    protected override Record[] getRecords(Event? e)
    {
        return recordExplorer(e).getSelected
    }

    protected override Void afterEdit(Event? e, Record[] records)
    {
        recExp := recordExplorer(e)
        prj := pbp.prj

        recExp.update(prj.database.getClassMap(records.first.typeof))
        recExp.refreshAll
    }
}

