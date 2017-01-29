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

abstract class AbstractDeleteRec : Command
{
    protected PbpListener pbp

    new make(PbpListener pbp) : super.makeLocale(Pod.find("projectBuilder"), "remRec")
    {
        this.pbp = pbp
    }

    protected abstract Record[] getRecords(Event? e)

    protected abstract Void afterDelete(Event? e, Record[] records)

    override Void invoked(Event? e)
    {
        prj := pbp.prj

        Record[] todelete := getRecords(e)

        warning := Dialog.openWarn(e.window, "Are you sure you want to delete ${todelete.size} Records?", null, [Dialog.ok(), Dialog.cancel()])

        if (warning == Dialog.cancel()) { return }

        ActorPool newPool := ActorPool()
        ProgressWindow pwindow := ProgressWindow(e.window, newPool)
        DatabaseThread dbthread := prj.database.getSyncThreadSafe(todelete.size, pwindow.phandler, newPool)
        todelete.each |rec|
        {
            dbthread.send([DatabaseThread.REMOVE, rec])
        }

        pwindow.open()
        newPool.stop()
        newPool.join()
        prj.database.unlock()

        afterDelete(e, todelete)
    }
}

class DeleteRec : AbstractDeleteRec
{
    new make(PbpListener pbp) : super.make(pbp) { }

    private static RecordExplorer recordExplorer(Event? e)
    {
        return e.widget.parent.parent as RecordExplorer ?: throw Err("Invalid state. e.widget.parent.parent is not RecordExplorer")
    }

    protected override Record[] getRecords(Event? e)
    {
        return recordExplorer(e).getSelected
    }

    protected override Void afterDelete(Event? e, Record[] records)
    {
        recordExplorer := recordExplorer(e)
        prj := pbp.prj

        recordExplorer.update(prj.database.getClassMap(records.first.typeof))
        recordExplorer.refreshAll
    }

}
