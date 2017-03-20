/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

class Wizard : PbpWindow
{
  InstructionBox[] boxes
  Text? nameText
  GridPane instructionWrapper := GridPane{numCols = 1}
  EdgePane leftWrapper := EdgePane{}
  TagExplorer tagExp
  SashPane mainWrapper := SashPane{}
  new make(Window? parent, |This|? f) : super(parent)
  {
    f(this)
  }

  override Obj? open()
  {
    boxes.each|box|
    {
      instructionWrapper.add(SelectableBorderPane{
      border=Border("1,1,1,1 #000")//TODO: CHANGE LATER
      box,
      })
    }
  leftWrapper.center = ScrollPane{
    instructionWrapper,
    }
  mainWrapper.add(leftWrapper)
  mainWrapper.add(tagExp)
  mainWrapper.weights = [792,260]
  content = mainWrapper
  size = Size(1092,718)
  super.open
  return null
  }

  Void addBox(InstructionBox box)
  {
    boxes.push(box)
    instructionWrapper.add(SelectableBorderPane{
      border=Border("1,1,1,1 #000")//TODO: CHANGE LATER
      box,
      })
    instructionWrapper.relayout
    instructionWrapper.parent.relayout
    instructionWrapper.parent.parent.relayout
    instructionWrapper.parent.parent.parent.relayout
    }
}
