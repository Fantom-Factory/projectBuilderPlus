/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpgui
using concurrent

class SqlPackageEditor : PbpWindow
{
  SqlPackageEditPane[] editPanes
  EdgePane mainWrapper := EdgePane{}
  TabPane tabPane := TabPane{}

  new make(Window? parentwindow, SqlPackageEditPane[] editPanes) : super(parentwindow)
  {
    this.editPanes = editPanes
    editPanes.each |pane|
    {
      tabPane.add(Tab{text=pane.name; EdgePane{center=ScrollPane{pane,};},})
    }
  }

  override Obj? open()
  {
    mainWrapper.center = tabPane
    mainWrapper.bottom = ButtonGrid{numCols=1; Button(Dialog.ok),}
    content = mainWrapper
    super.open()
    return null
  }
}
