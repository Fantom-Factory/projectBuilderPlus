/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

**
** ToolbBarLeftRight
** A toolbar that can lign up items(commands) both far left and far right
**
class ToolBarLeftRight : EdgePane
{
  private ToolBar leftTb := ToolBar {orientation = Orientation.horizontal}
  private ToolBar rightTb := ToolBar {orientation = Orientation.horizontal}

  new make()
  {
    left = leftTb
    right = rightTb
  }

  Void addLeftSep() {leftTb.addSep}
  Void addRightSep() {rightTb.addSep}
  Button addLeftCommand(Command c) {leftTb.addCommand(c)}
  Button addRightCommand(Command c) {rightTb.addCommand(c)}
}
