/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore

class InstructionSmartBox : SmartBox
{
  new make(Tag tag) : super(tag)
  {
    super.deleteButton.onAction.add |e|
    {
      //InstructionBox -> Instruction ->
      Instruction parent := e.widget.parent.parent.parent
      parent.fieldWrapper.remove(e.widget.parent)
      //parent.fieldWrapper.remove(parent.fieldWrapper.children.first)
      parent.fieldWrapper.relayout
      parent.relayout
      parent.parent.relayout
      parent.parent.parent.relayout
      parent.parent.parent.parent.relayout
    }
  }

}
