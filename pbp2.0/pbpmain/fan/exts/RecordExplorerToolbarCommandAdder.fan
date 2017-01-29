/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpgui
using fwt

class RecordExplorerToolbarCommandAdder : ToolbarCommandAdder
{
    private RecordExplorer recordExplorer

    new make(RecordExplorer recordExplorer)
    {
        this.recordExplorer = recordExplorer
    }

    override Void addCommand(Str toolbarId, Command command)
    {
        recordExplorer.addToolbarCommand(command)
    }
}
