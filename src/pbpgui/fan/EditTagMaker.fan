/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore

class EditTagMaker : GridPane
{
  Tag? tag
  Text tagName
  Text tagType

  new make(Tag tag)
  {
    this.tag = tag;
    numCols = 2;
    tagType = Text{text=tag->kind; it.enabled=false}
    tagName = Text{text=tag.name;}
    add(tagName)
    add(tagType)

  }

  Tag getNewTag()
  {
    return TagFactory.rename(tag, tagName.text)
  }
}
