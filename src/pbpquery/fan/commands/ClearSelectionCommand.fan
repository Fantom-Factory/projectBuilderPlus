/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using projectBuilder
using fwt

class ClearSelectionCommand : Command
{
    private SearcherPane searcherPane

    new make(SearcherPane searcherPane) : super.makeLocale(Pod.find("projectBuilder"), "clearRecSel")
    {
        this.searcherPane = searcherPane
    }

    override Void invoked(Event? e)
    {
        searcherPane.clearSelection
    }
}
