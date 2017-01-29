/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

class UploadDialog : Dialog {

  Bool useDisMacro := false

  new make(Window? parent, |This|? f := null)
    : super(parent, f)
  {
    icon = parent?.icon
  }

  static Obj:Obj openUploadDialog(Window? parent, Str msg, Str def := "", Int prefCols := 20)
  {
    field := Text { it.text = def; it.prefCols = prefCols }

    checkBox := Button {
        mode = ButtonMode.check;
        text = "Use disMacro"
    }
    
    pane := GridPane {
      numCols = 1
      expandCol = 1
      halignCells = Halign.fill
      Label { text=msg },
      GridPane {
        add(checkBox)
      }
    }
    
    field.onAction.add |Event e| { e.widget.window.close(ok); }

    result := openMsgBox(Dialog#.pod, "question", parent, pane, Dialog.yesNo)
    if (result == Dialog.no) {
      return ["result": false]
    }
    return ["result": true, "useDisMacro": checkBox.selected]
  }
}
