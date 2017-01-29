/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using pbpcore
using pbpgui

class EditRecordCommand : AbstractEditRec
{
    private SearcherPane searcherPane

    new make(PbpListener pbp, SearcherPane searcherPane) : super.make(pbp)
    {
        this.searcherPane = searcherPane
    }

    protected override Record[] getRecords(Event? e)
    {
        return searcherPane.getSelectedPoints()
    }

    protected override Void afterEdit(Event? e, Record[] records)
    {
        searcherPane.update()
        searcherPane.refreshAll()

        ws := pbp.workspace as PbpWorkspace ?: throw Err("Unable to get ${PbpWorkspace#}")

        ws.siteExplorer.update(pbp.prj.database.getClassMap(Site#))
        ws.siteExplorer.refreshAll()

        ws.equipExplorer.update(pbp.prj.database.getClassMap(Equip#))
        ws.equipExplorer.refreshAll()

        ws.pointExplorer.update(pbp.prj.database.getClassMap(Point#))
        ws.pointExplorer.refreshAll()
    }

}
