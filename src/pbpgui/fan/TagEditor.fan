/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore

class TagEditor : PbpWindow
{
  EdgePane contentWrapper := EdgePane{}
  SashPane mainWrapper := SashPane{}
  TagExplorer tagExp
  TagLib tagLib
  TagEditPane tageditpane := TagEditPane{numCols = 1;}

  new make(Window? parent, TagLib tagLib):super(parent)
  {
    this.tagLib = tagLib
    contentWrapper.center = InsetPane(0,0,0,0){ScrollPane{tageditpane,},}

    tagExp = TagExplorer.makeWithToolbar(tagLib.tagLibFile, EditTagInLib(this), ToolBar(), true)
    tagExp.addToolbarCommand(DeleteTagFromLib(this))

     mainWrapper.add(contentWrapper)
     mainWrapper.add(tagExp)
     mainWrapper.weights = [700,320]
     content = mainWrapper
  }

  override Obj? open()
  {
    size = Size(1020,561)
    super.open()
    return null
  }

}
