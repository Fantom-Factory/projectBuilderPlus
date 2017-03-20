/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore

class ProjectSelector : PbpWindow
{
  ProjectExplorer explorer
  new make(Window? parent, PbpListener pbpListener):super(parent)
  {
    explorer = ProjectExplorer(FileUtil.projectDirectory, pbpListener)
  }


  override Obj? open()
  {
    GridPane buttonWrapper := GridPane
    {
      numCols = 1
      halignPane = Halign.right
      Button{text="Done"; onAction.add|e|{e.window.close}},
    }
    content = EdgePane{
      top = Label{text="Please choose the projects you would like to use: "}
      center = explorer
      bottom = buttonWrapper
      }
    size = Size(454,345)
    super.open
    return explorer.getSelected
  }
}
