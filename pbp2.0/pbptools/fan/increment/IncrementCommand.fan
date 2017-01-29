/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using pbpcore
using pbpgui
using projectBuilder
using pbpquery

abstract class AbstractIncrementCommand : Command
{
    protected Str toolbarId
    protected ProjectBuilder projectBuilder

    new make(Str toolbarId, ProjectBuilder projectBuilder) : super.makeLocale(AbstractIncrementCommand#.pod, "incrementCommand")
    {
        this.toolbarId = toolbarId
        this.projectBuilder = projectBuilder
    }

    protected override Void invoked(Event? event)
    {
        if (projectBuilder.currentProject == null)
        {
            Dialog.openErr(event.window, "No project opened!")
            return
        }

        records := getSelectedRecords()

        if (records.isEmpty)
        {
            Dialog.openInfo(event.window, "No records selected! Please select records.")
        }
        else
        {
            IncrementWindow(toolbarId, projectBuilder, getSelectedRecords(), createAfterUpdateFunc()).open()
        }
    }

    protected abstract Record[] getSelectedRecords()

    protected abstract |->| createAfterUpdateFunc()
}

@ToolbarExt{toolbarIds = ["siteToolbar", "equipToolbar", "pointToolbar"]}
class IncrementRecordExplorerCommand : AbstractIncrementCommand
{
    new make(Str toolbarId, ProjectBuilder projectBuilder) : super.make(toolbarId, projectBuilder)
    {
    }

    protected override Record[] getSelectedRecords()
    {
        switch (toolbarId)
        {
            case "siteToolbar": return projectBuilder.getSiteToolbar().getSelected()
            case "equipToolbar": return projectBuilder.getEquipToolbar().getSelected()
            case "pointToolbar": return projectBuilder.getPointToolbar().getSelected()
        }

        throw Err("Invalid toolbar id $toolbarId")
    }


    protected override |->| createAfterUpdateFunc()
    {
        return |->|
        {
            ws := projectBuilder.workspace as PbpWorkspace ?: throw Err("Unable to get ${PbpWorkspace#}")

            switch (toolbarId)
            {
                case "siteToolbar":
                    ws.siteExplorer.update(projectBuilder.prj.database.getClassMap(Site#))
                    ws.siteExplorer.refreshAll()
                case "equipToolbar":
                    ws.equipExplorer.update(projectBuilder.prj.database.getClassMap(Equip#))
                    ws.equipExplorer.refreshAll()
                case "pointToolbar":
                    ws.pointExplorer.update(projectBuilder.prj.database.getClassMap(pbpcore::Point#))
                    ws.pointExplorer.refreshAll()
                default:
                    throw Err("Invalid toolbar id $toolbarId")
            }
        }
    }
}

@ToolbarExt{toolbarIds = ["queryToolbar"]}
class IncrementQueryCommand : AbstractIncrementCommand
{
    private SearcherPane searcherPane

    new make(Str toolbarId, ProjectBuilder projectBuilder, SearcherPane searcherPane) : super.make(toolbarId, projectBuilder)
    {
        this.searcherPane = searcherPane
    }

    protected override Record[] getSelectedRecords()
    {
        return searcherPane.getSelectedPoints()
    }

    protected override |->| createAfterUpdateFunc()
    {
        return |->|
        {
            searcherPane.update()
            searcherPane.refreshAll()

            ws := projectBuilder.workspace as PbpWorkspace ?: throw Err("Unable to get ${PbpWorkspace#}")

            ws.siteExplorer.update(projectBuilder.prj.database.getClassMap(Site#))
            ws.siteExplorer.refreshAll()

            ws.equipExplorer.update(projectBuilder.prj.database.getClassMap(Equip#))
            ws.equipExplorer.refreshAll()

            ws.pointExplorer.update(projectBuilder.prj.database.getClassMap(pbpcore::Point#))
            ws.pointExplorer.refreshAll()
        }
    }
}
