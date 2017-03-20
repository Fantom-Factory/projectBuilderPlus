/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx



class InstructionText : Text
{
  new make(Str dis) : super()
  {
    text = dis
    border = false
    //bg = Desktop.sysBg
    font = Font{it.size=32; name = "Sans Serif"}
  }
}
