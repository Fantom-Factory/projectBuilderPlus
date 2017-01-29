/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore

class LibEditor : PbpWindow
{
  File libDir //TODO: remove this
  Table libTable := Table{}
  //TODO: Button class we set button size...
  Button? newLibButton
  Button? addLibButton
  Button? deleteLibButton
  Button? makeLibButton
  Button? editLibButton
  Button? closeButton := Button{text="Close"; onAction.add |e|{e.window.close}}
  GridPane buttonWrapper := GridPane{numCols = 1}
  EdgePane mainWrapper := EdgePane{}
  GridPane bottomWrapper := GridPane{numCols = 1; halignPane = Halign.right; }
  Str? name := ""

   new make(Window? parent, File libDir): super(parent)
  {
    this.libDir = libDir
  }

  override Obj? open()
  {
    buttonWrapper.add(newLibButton)
    buttonWrapper.add(addLibButton)
    buttonWrapper.add(deleteLibButton)
    buttonWrapper.add(editLibButton)
    buttonWrapper.add(makeLibButton)
    bottomWrapper.add(closeButton)
    mainWrapper.right = buttonWrapper
    mainWrapper.center = libTable
    mainWrapper.top = Label{text= "Libraries: "}
    mainWrapper.bottom = bottomWrapper
    title = "${name} Library Editor"
    content = mainWrapper
    size = Size(450,440)
    super.open()
    return null
  }

}
