/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore
using fwt
using gfx

class TagExplorer : EdgePane
{
  private GridPane? topGridPane
  private ToolBar? toolbar
  private Combo? combo
  Table tagTable { private set }
  TagTableModel tagTableModel { private set }

  new makeWithToolbarAndCombo(File tagLibFile, Command? addBtnCommand, ToolBar toolbar, Combo combo, Bool multiTable) : this.make(tagLibFile, addBtnCommand, multiTable)
  {
    this.toolbar = toolbar
    this.combo = combo
    this.top = topGridPane = GridPane{ numCols = 2; this.toolbar, this.combo, }
    relayout
  }

  new makeWithCombo(File tagLibFile, Command? addBtnCommand, Combo combo, Bool multiTable) : this.make(tagLibFile, addBtnCommand, multiTable)
  {
    this.combo = combo
    this.top = topGridPane = GridPane{ numCols = 1; this.combo, }
    relayout
  }

  new makeWithToolbar(File tagLibFile, Command? addBtnCommand, ToolBar toolbar, Bool multiTable) : this.make(tagLibFile, addBtnCommand, multiTable)
  {
    this.toolbar = toolbar
    this.top = topGridPane = GridPane{ numCols = 1; this.toolbar, }
    relayout
  }

  new make(File tagLibFile, Command? addBtnCommand, Bool multiTable) : super()
  {
    this.tagTableModel = TagTableModel(tagLibFile)
    this.tagTable = Table() { it.model = tagTableModel; it.multi = multiTable }
    this.tagTable.refreshAll

    center = tagTable

    if (addBtnCommand != null)
    {
        this.addBtnCommand(addBtnCommand)
    }
  }

  Void addBtnCommand(Command command)
  {
    left = Button(command)
    relayout
  }

  Void addToolbarCommand(Command command)
  {
    if (toolbar == null) throw Err("Can not add command to non existing toolbar. TagExplorer was created without toolbar.");

    toolbar.addCommand(command)
  }

  Void addOnTablePopup(|Event e| popupFunc)
  {
    tagTable.onPopup.add(popupFunc)
  }

  Void setToolbarWithCombo(ToolBar toolbar, Combo combo)
  {
    if (topGridPane == null) throw Err("Can not add toolbar and combo to top. TagExplorer was created without toolbar and combo.");

    topGridPane.removeAll
    topGridPane.add(toolbar)
    topGridPane.add(combo)

    topGridPane.relayout
    relayout
  }

  Tag[] getSelected()
  {
    tagTableModel.getRows(tagTable.selected)
  }

}
