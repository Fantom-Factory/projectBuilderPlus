/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpgui

class RepoWindow : PbpWindow
{
  Table repoTable := Table{multi=true}
  EdgePane mainWrapper := EdgePane{}
  ToolBar repoToolbar := ToolBar{}
  TableModel repoTableModel
  //Install Button
  //Download Button
  //Refresh Repo Button
  new make(Window? parent, |This| f) : super(parent)
  {
    f(this)
  }
  override Obj? open()
  {
    size = Size(425,367)
    repoTable.model = repoTableModel
    mainWrapper.center = repoTable
    mainWrapper.top = repoToolbar
    mainWrapper.bottom = GridPane{ halignPane = Halign.right; Button{text="Close"; onAction.add|e|{e.window.close}},}
    content = mainWrapper
    super.open()
    return null
  }
}

