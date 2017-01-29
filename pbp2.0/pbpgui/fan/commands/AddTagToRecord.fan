/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using concurrent
using pbpcore

class AddTagToRecord : Command
{
    private TagExplorer tagExplorer
    private PbpListener pbp
    private Type[] types
    new make(PbpListener pbp, TagExplorer tagExplorer) : super.makeLocale(Pod.find("projectBuilder"),"addTags")
    {
        this.pbp = pbp
        this.tagExplorer = tagExplorer
        this.types = Type[Type.find("pbpgui::RecordExplorer"), Type.find("pbpquery::SearcherPane")]
    }

    override Void invoked(Event? e)
    {
        prj := pbp.prj
        PbpWorkspace workspace := pbp.workspace

        builder := pbp.getBuilder as Builder ?: throw Err()
        if (builder._recordTabs.selected == null)
        {
            return
        }

        Record[] newRecs := [,]

        selectedWidget := WidgetUtils.findWidgetOfType(builder._recordTabs.selected.children, types)

        Tag[] tags := tagExplorer.getSelected

        if (pbp.isSiteRecordsExplorer(selectedWidget))
        {
            Record[] siteFiles := workspace.siteExplorer.getSelected
            applyTagsToRecords(siteFiles, newRecs, tags)

        }
        else if (pbp.isEquipRecordsExplorer(selectedWidget))
        {
            Record[] equipFiles := workspace.equipExplorer.getSelected
            applyTagsToRecords(equipFiles, newRecs, tags)
        }
        else if (pbp.isPointRecordsExplorer(selectedWidget))
        {
            Record[] pointFiles := workspace.pointExplorer.getSelected
            applyTagsToRecords(pointFiles, newRecs, tags)
        }
        else if (pbp.isQueryRecordsExplorer(selectedWidget))
        {
            Record[] auxRecs := [,]
            Map auxWidgets := pbp.callback("getAuxWidgets")
            if (auxWidgets.containsKey("latestwb"))
            {
                RecordSpace space := auxWidgets["latestwb"]
                auxRecs.addAll(space.getSelectedPoints)
            }

            applyTagsToRecords(auxRecs, newRecs, tags)
        }

        if (!newRecs.isEmpty)
        {
            saveRecords(newRecs, prj, e)

            workspace.siteExplorer.update(prj.database.getClassMap(Site#))
            workspace.siteExplorer.refreshAll
            workspace.equipExplorer.update(prj.database.getClassMap(Equip#))
            workspace.equipExplorer.refreshAll
            workspace.pointExplorer.update(prj.database.getClassMap(pbpcore::Point#))
            workspace.pointExplorer.refreshAll
        }
    }


    private Void applyTagsToRecords(Record[] selectedRecs, Record[] newRecs, Tag[] tags)
    {
        selectedRecs.each |rec|
        {
            newRecs.push(rec.addAll(tags))
        }
    }

    private static Void saveRecords(Record[] newRecs, Project prj, Event e)
    {
        ActorPool newpool := ActorPool()
        ProgressWindow progressWindow := ProgressWindow(e.window, newpool)
        DatabaseThread dbthread := prj.database.getThreadSafe(newRecs.size, progressWindow.phandler, newpool)
        newRecs.each |rec|
        {
            dbthread.send([DatabaseThread.SAVE,rec])
        }
        progressWindow.open()
        newpool.stop()
        newpool.join()
        prj.database.unlock();
    }
}
