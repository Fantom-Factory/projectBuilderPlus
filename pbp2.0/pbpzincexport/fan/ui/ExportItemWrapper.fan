/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using pbpgui

class ExportItemWrapper : MenuItemWrapper
{
  Command command
  Str name
  new make(Command command, Str name)
  {
    this.command = command
    this.name = name
  }

  override MenuItem getItem(Event? e)
  {
    MenuItem{
      text=name
      onAction.add |g| {
        command.invoke(e)
      }
  }
  }
}
