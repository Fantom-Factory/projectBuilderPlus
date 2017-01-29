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

abstract class AbstractMapCommand : Command
{
    protected Str toolbarId
    protected ProjectBuilder projectBuilder

    new make(Str toolbarId, ProjectBuilder projectBuilder) : super.makeLocale(AbstractMapCommand#.pod, "mapCommand")
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
            MapWindow(toolbarId, projectBuilder, getSelectedRecords(), createAfterUpdateFunc()).open()
        }
    }

    protected abstract Record[] getSelectedRecords()

    protected abstract |->| createAfterUpdateFunc()

}


@ToolbarExt{toolbarIds = ["equipToolbar", "pointToolbar"]}
class MapCommand : AbstractMapCommand
{
    new make(Str toolbarId, ProjectBuilder projectBuilder) : super.make(toolbarId, projectBuilder)
    {
    }

    protected override Record[] getSelectedRecords()
    {
        switch (toolbarId)
        {
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
