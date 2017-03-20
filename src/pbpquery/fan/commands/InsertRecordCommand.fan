/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore
using pbpgui
using fwt
using gfx

class InsertRecordCommand : Command
{
    private PbpListener pbp
    private SearcherPane searcherPane

    new make(PbpListener pbp, SearcherPane searcherPane) : super.makeLocale(Pod.find("projectBuilder"), "addSite")
    {
        this.pbp = pbp
        this.searcherPane = searcherPane

        this.onInvoke.add |Event event|
        {
            // parent can not be widget, because of when command is added to ToolBar instance of ToolItem is created
            // ToolItem is not supported at Menu.open()

            // position is relative to Toolbar
            createPopup().open(event.widget.parent, event.widget.pos.translate(gfx::Point(0, event.widget.size.h)))
        }
    }

    private Menu createPopup()
    {
        return Menu()
        {
            createSiteMenuItem(),
            createEquipMenuItem(),
            createPointMenuItem(),
        }
    }

    private MenuItem createSiteMenuItem()
    {
        return MenuItem()
        {
            it.text = "Add Site";
            it.onAction.add |e|
            {
                QueryAddSite(pbp, searcherPane).invoked(null)
            }
        }
    }

    private MenuItem createEquipMenuItem()
    {
        ws := pbp.workspace as PbpWorkspace ?: throw Err("Unable to get ${PbpWorkspace#}")

        records := ws.siteExplorer.getSelected
        msg := records.isEmpty ? "(parent Site not selected)" : "to Site ${records.first}"

        return MenuItem()
        {
            it.text = "Add Equip ${msg}";
            it.enabled = !records.isEmpty
            it.onAction.add |e|
            {
                QueryAddEquip(pbp, searcherPane).invoked(null)
            }
        }
    }

    private MenuItem createPointMenuItem()
    {
        ws := pbp.workspace as PbpWorkspace ?: throw Err("Unable to get ${PbpWorkspace#}")

        records := ws.equipExplorer.getSelected
        msg := records.isEmpty ? "(parent Equip not selected)" : "to Equip ${records.first}"

        return MenuItem()
        {
            it.text = "Add Point ${msg}";
            it.enabled = !records.isEmpty
            it.onAction.add |e|
            {
                QueryAddPoint(pbp, searcherPane).invoked(null)
            }
        }
    }
}

// ---------------------------------------------------------------------------------------------------------------------

class QueryAddEquip : AddEquip
{
    private SearcherPane searcherPane

    new make(PbpListener pbp, SearcherPane searcherPane) : super.make(pbp)
    {
        this.searcherPane = searcherPane
    }

    protected override Void afterInvoked(Event? e)
    {
        searcherPane.update()
        searcherPane.refreshAll()

        super.afterInvoked(e)
    }
}

// ---------------------------------------------------------------------------------------------------------------------

class QueryAddSite : AddSite
{
    private SearcherPane searcherPane

    new make(PbpListener pbp, SearcherPane searcherPane) : super.make(pbp)
    {
        this.searcherPane = searcherPane
    }

    protected override Void afterInvoked(Event? e)
    {
        searcherPane.update()
        searcherPane.refreshAll()

        super.afterInvoked(e)
    }
}

// ---------------------------------------------------------------------------------------------------------------------

class QueryAddPoint : AddPoint
{
    private SearcherPane searcherPane

    new make(PbpListener pbp, SearcherPane searcherPane) : super.make(pbp)
    {
        this.searcherPane = searcherPane
    }

    protected override Void afterInvoked(Event? e)
    {
        searcherPane.update()
        searcherPane.refreshAll()

        super.afterInvoked(e)
    }
}

