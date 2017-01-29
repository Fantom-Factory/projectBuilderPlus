/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore
using pbpgui


class UnitHelperCommand : Command
{
  new make() : super.makeLocale(Pod.of(this), "unitHelper")
  {
  }

  override Void invoked(Event? event)
  {
    Unit[] units := Unit.list()

    GridPane mainWrapper := GridPane{numCols = 2}
    ScrollPane bigWrapper := ScrollPane{}
    units.each |unit|
    {
      mainWrapper.add(Label{text=unit.ids.toStr})
      mainWrapper.add(Button{text="Copy"; onAction.add|e|
      {
        Desktop.clipboard.setText(unit.name)
      }
      })
    }
    bigWrapper.add(mainWrapper)
    EdgePane superWrapper := EdgePane{
      center = bigWrapper
      bottom = ButtonGrid{numCols=1; Button(Dialog.ok),}
    }
    Window window := PbpWindow(event.window)
    {
      size = Size(371,1023)
      content = superWrapper
    }
    window.open()
  }
}

class TimezoneHelperCommand : Command
{
  new make() : super.makeLocale(Pod.of(this), "tzHelper")
  {
  }

  override Void invoked(Event? event)
  {
    Str[] tzs := TimeZone.listNames()

    GridPane mainWrapper := GridPane{numCols = 2}
    ScrollPane bigWrapper := ScrollPane{}
    tzs.each |tz|
    {
      mainWrapper.add(Label{text=tz})
      mainWrapper.add(Button{text="Copy"; onAction.add|e|
      {
        Desktop.clipboard.setText(tz)
      }
      })
    }
    bigWrapper.add(mainWrapper)
    EdgePane superWrapper := EdgePane{
      center = bigWrapper
      bottom = ButtonGrid{numCols=1; Button(Dialog.ok),}
    }
    Window window := PbpWindow(event.window)
    {
      size = Size(371,1023)
      content = superWrapper
    }
    window.open()
  }
}
