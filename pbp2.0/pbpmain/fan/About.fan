/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpi
using pbpgui

class About : PbpWindow
{

  new make(Window? parent):super(parent)
  {
    mode = WindowMode.windowModal
  }

  override Obj? open()
  {
    Image pbpIcon16 := PBPIcons.pbpIcon16
    Image pbpIcon64 := PBPIcons.pbpIcon64
    title = "About Project Builder Plus"
    icon = pbpIcon16

    content = EdgePane{
      left = Label {
                     image = pbpIcon64
                  }
      center = GridPane{numCols = 1; halignPane=Halign.center;
                       Label{ text="BAS Project Builder Plus ${Pod.of(this).version}"},
                       Label{ text="Copyright © 2014 BAS Services and Graphics, LLC. All Rights Reserved"},
                       Label{ text=""},
                       }
      bottom = GridPane{numCols = 1; halignPane=Halign.center; Button{text="Close"; onAction.add|e|{e.window.close}},}
    }
    super.open()
    return null
  }

}

class AboutCommand : Command
{
  new make():super.makeLocale(Pod.of(this), "aboutInfo")
  {

  }

  override Void invoked(Event? e)
  {
    About(e.window).open

  }
}
