/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

class InstructionBox : GridPane
{
  Str dis
  Text disText
  Instruction[] instructions
  Bool selected := false //TODO: put this in a mixin
  Bool mousein := false
  Bool disable
  new make(Str dis , Instruction[] instructions, Bool disable := false)
  {

    this.dis = dis
    this.instructions = instructions
    disText = InstructionText(dis)
    add(disText)
    instructions.each |inst, index|
    {
      inst.prependNum(index)
      add(inst)
    }

    onMouseEnter.add |e|
      {
        mousein=true
        if(!selected && !disable)
        {
          (e.widget.parent as SelectableBorderPane).border = Border("1,1,1,1 #00f")
          e.widget.parent.repaint
        }
        else if(!disable)
        {
          (e.widget.parent as SelectableBorderPane).border = Border("1,1,1,1 #47f53b")
          e.widget.parent.repaint
        }
      }

      onMouseExit.add |e|
      {
        mousein=false
        if(!selected && !disable)
        {
          (e.widget.parent as SelectableBorderPane).border = Border("1,1,1,1 #000")
          e.widget.parent.repaint
        }
        else if(!disable)
        {
          (e.widget.parent as SelectableBorderPane).border = Border("1,1,1,1 #47f53b")
          e.widget.parent.repaint
        }
      }

      onMouseUp.add|e|
      {
        if(mousein && !disable)
        {
          selected = selected.not
          (e.widget.parent as SelectableBorderPane).border = Border("1,1,1,1 #00f")
          e.widget.parent.repaint
        }
      }
  }

  override Void onLayout()
  {
    disText.pos = gfx::Point.defVal
    disText.size = disText.prefSize
    super.onLayout
  }

/*
  override Size prefSize(Hints hints:=Hints.defVal)
  {
    if(super.prefSize(hints).h < 672)
    {
      return Size(307,672)
    }
    else
    {
      return Size(307,super.prefSize(hints).h)
    }
  }
*/
}
