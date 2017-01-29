/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpgui
using pbpcore
using projectBuilder

class UserValHolder : EdgePane
{
  GridPane valholder := GridPane{it.numCols=1;}
  Button makeNewInput
  new make(Str[] vals)
  {
    vals.each |val|
    {
      valholder.add(Text{text=val})
    }
   makeNewInput = Button{
     text="Add Field"
     onAction.add |e|
     {
     valholder.add(Text{text=""})
     valholder.relayout
     valholder.parent.relayout
     valholder.parent.parent.relayout
     valholder.parent.parent.parent.relayout
     }
   }
   top=makeNewInput
   center=ScrollPane{valholder,}
  }
}
