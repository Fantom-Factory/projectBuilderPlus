/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

class Instruction : GridPane
{
  Label desc
  GridPane fieldWrapper
  Str? id

  new make(Str desc, Str? id := null)
  {
    numCols = 1;
    this.id = id
    this.desc = SelectableLabel(desc)
    this.fieldWrapper = GridPane{it.numCols = 1;}
    add(this.desc)
    add(fieldWrapper)
  }

  Void prependNum(Int numb)
  {
    newtext := (numb+1).toStr+". "+desc.text
    desc = SelectableLabel(newtext)
    removeAll
    add(desc)
    add(fieldWrapper)
  }

  virtual This addField(Widget field)
  {
    //fieldWrapper.add(Spacer())
    fieldWrapper.add(field)
    field.relayout
    fieldWrapper.relayout
    return this
  }




}

class Spacer : Label
{
  new make() : super()
  {
  }
  override Size prefSize(Hints hints := Hints.defVal)
  {
    return Size(20,20)
  }
}


