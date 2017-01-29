/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore
using fwt

class ExportToZincCommand : Command
{
    private PbpListener projectBuilder

    new make(PbpListener pbp) : super.makeLocale(ExportToZincCommand#.pod, "exportToZincCommand")
    {
        this.projectBuilder = pbp
    }

    override Void invoked(Event? event)
    {
        treeWidget := event.widget as Tree
        if(treeWidget != null)
        {
            RecordTreeNode[] selectedNodes := treeWidget.selected
            if(!selectedNodes.isEmpty)
            {
                ExportWindow(projectBuilder, selectedNodes).open()
            }

        }

    }

}
