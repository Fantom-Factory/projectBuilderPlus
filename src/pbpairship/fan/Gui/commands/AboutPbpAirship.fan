/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using projectBuilder
using pbpgui

class AboutPbpAirship : Command
{
  ProjectBuilder pbp
  new make(ProjectBuilder pbp) : super.makeLocale(Pod.of(this), "aboutPbpAirship")
  {
    this.pbp = pbp
  }

  override Void invoked(Event? event)
  {
    AboutPbpWindow(event.window).open()
  }
}

class AboutPbpWindow : PbpWindow
{
  EdgePane mainWrapper := EdgePane{}
  new make(Window parentWindow) : super(parentWindow)
  {

  }

  override Obj? open()
  {

    File? logFile := Env.cur.homeDir.listFiles.find |File f-> Bool| {return (f.basename=="projectbuilder-"+Date.today.toLocale("YYMM")).and(f.ext=="log")}
    if(logFile!=null)
    {
      //mainWrapper.center = Label{text=logFile.readAllLines.join("\n")}
      mainWrapper.center = ScrollPane{
        it.content=InsetPane{
           Label{
          text=logFile.readAllLines.findAll |Str s -> Bool|{
            return s.contains("[pbpairship]").and(s.contains("[info]"))}.join("\n")
            },
            }
            }
    }
    else
    {
    mainWrapper.center = GridPane{Label{text="Coming Soon, A window nearby"},}
    }
    mainWrapper.bottom = ButtonGrid{numCols=1; Button(Dialog.ok),}
    content = mainWrapper
    super.open()
    return null
  }
}
