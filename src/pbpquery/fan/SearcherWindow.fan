/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpgui

class SearcherWindow : Window
{
    Table table
    Text text

    Searcher searcher
    new make(Window parentWin, Searcher searcher) : super(parentWin) {
    this.searcher = searcher
    table = Table{
      multi=true
      onPopup.add |e| {e.popup = PbpUtil.makeRecTablePopup(searcher.pbp, e, searcher.pbp.currentProject.database.getClassMap(pbpcore::Point#))}
      model = RecTableModel([:], searcher.pbp.currentProject)
    }
    text = Text{
      onAction.add |e| {
        (table.model as RecTableModel).update(searcher.query((e.widget as Text).text))
        table.refreshAll
      }
    }

    }

    override Obj? open()
    {
      title = "Test Window"
      size = Size(800,600)
      content = EdgePane{
        center = table
        bottom = text
      }
      super.open()
      return null
    }

}


