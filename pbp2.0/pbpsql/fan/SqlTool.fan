/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpgui
**
** This class encapsulates a sqltool
**
mixin SqlTool{
  abstract Str name
  virtual Widget[] enablement(){
   Button setButton := Button{
      mode = ButtonMode.check
    }
    Label nameLabel := Label{text=name}

    return [nameLabel, setButton]
    }
  abstract Void run();
  virtual Void open(Obj? edata, Window? parentw){}

   Widget guiTemplate(Window? parent, Size winsize, Widget toolcontent){
    Window templateWindow := PbpWindow(null)
    EdgePane skeleton := EdgePane()
    InsetPane contentWrapper := InsetPane(1,1,1,1){content = toolcontent}
    EdgePane buttonSkeleton := EdgePane{left=Button{text="close"; onAction.add|e|{e.window.close}}}

    skeleton = EdgePane{
      center= contentWrapper
      bottom= buttonSkeleton
    }
    if(parent != null)
    {
      templateWindow = Window(parent){
        content = skeleton
      }
    }
    else
    {
      templateWindow = Window(){
      size = winsize
      content = skeleton
      }
    }
    return templateWindow
  }

}
