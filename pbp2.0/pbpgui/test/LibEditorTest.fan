/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

class LibEditorTest : Test
{

  Void testEditor()
  {
    LibEditor libeditor := LibEditor(null,Env.cur.homeDir+`resources/tags/`)
    libeditor.newLibButton = Button{text="New Library"}
    libeditor.addLibButton = Button{text="Add Library"}
    libeditor.deleteLibButton = Button{text="Delete Library"}
    libeditor.makeLibButton = Button{text="Make Default"}
    libeditor.libTable.model = TagLibTableModel(Env.cur.homeDir+`resources/tags/`, null)
    libeditor.open
  }

}
