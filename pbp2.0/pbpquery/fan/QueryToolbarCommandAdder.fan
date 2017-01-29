/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using projectBuilder
using fwt

class QueryToolbarCommandAdder : ToolbarCommandAdder
{
    private SearcherPane searcherPane

    new make(SearcherPane searcherPane)
    {
        this.searcherPane = searcherPane
    }

    override Void addCommand(Str toolbarId, Command command)
    {
        searcherPane.addToolbarCommand(command)
    }
}
