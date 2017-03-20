/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using concurrent

class SqlColSelector : Combo
{
  AtomicRef listRef
  Str currentText := ""
  new make(AtomicRef listRef) : super()
  {
    this.listRef = listRef
    editable = true;
    items = listRef.val
  }

  override Size prefSize(Hints hints := Hints.defVal)
  {
    return Size(140,super.prefSize(hints).h)
  }

  Void update()
  {
    currentText = this.text
    items = listRef.val
    text = currentText
  }

}
