/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpgui

class SqlToolHandler{
SqlTool[] registeredTools := [AutoAxonScriptSqlTool(),PbpImportSqlTool()]
static Void chooseTool(Obj? edata)
  {
    SqlToolHandler toolHandle := SqlToolHandler()
    GridPane toolLayout := GridPane{numCols = 2}
    EdgePane bodyLayout := EdgePane{}
    BorderPane toolStyler := BorderPane{
      bg = Color.white
      border = Border("#999999")
      //content = toolLayout
    }
    Widget[] toolQ := [,]
    //Add registeredTools to the tool bench
    toolHandle.registeredTools.each |tool|{
      toolQ.addAll(tool.enablement)
    }
    toolLayout.addAll(toolQ)

    bodyLayout = EdgePane{
      top = Label{text="Select Tools to apply: "}
      center = InsetPane(1,1,1,1){toolStyler,}
      bottom = EdgePane{right = Button{text="cancel"; onAction.add|e|{e.window.close}}}
    }

    Window toreturn := PbpWindow(null){
    size = Size(300,250)
    content = bodyLayout
    }
    toreturn.open
  }

}
