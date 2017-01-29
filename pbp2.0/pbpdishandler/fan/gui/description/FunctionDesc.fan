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

class FunctionDesc : Description, Compilable
{
  Str name := ""
  Text disText
  new make(Str name) : super()
  {
    this.name = name
    disText = Text{text=this.name}
    top = Label{text=title; font=Font { bold = true }}
    center = body()
  }
  override Str title()
  {
    return "Function"
  }

  override Widget body()
  {
   gp := GridPane{
    numCols=2;
    Label{text="Name "},
    disText,
    }
    return gp
  }
  override Str describe()
  {
    return "This is a Function Description"
  }

  override Obj compile()
  {
    return disText.text
  }
}
