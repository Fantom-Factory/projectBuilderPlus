/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore

class NewTagMaker : GridPane
{
  Tag? tag
  Text tagName
  Combo tagTypeSelector

  new make()
  {
    numCols = 2;
    tagTypeSelector = Combo
    {
      items = ["Bin","Bool","Date","DateTime","Marker","Num","Ref","Str","Time","Uri"]
    }
    tagName = Text{text="NewTag";}
    add(tagName)
    add(tagTypeSelector)

  }

  Tag getTag()
  {
    tag = TagFactory.fromKindStr(tagName.text,tagTypeSelector.selected)
    return tag
  }
}
