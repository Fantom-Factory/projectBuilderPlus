/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpgui
using pbpcore
using projectBuilder

class RuleDesc : Description, Compilable
{
  Tag[] tags
  RuleHolder tagthing
  new make(Tag[] tags) : super()
  {
    this.tags = tags
    this.tagthing = RuleHolder(tags)
     top = Label{text=title; font=Font { bold = true }}
    center = body()
  }
  override Str title()
  {
    return "Rules"
  }
  override Widget body()
  {
    // ScrollPane swapped with ContentPane. Pane not removed because of all parent.parent.parent... stuff
    return ContentPane{
      TabPane{
      Tab{
      text="Tag Rules"
      EdgePane{
        it.center = tagthing
        },
        },
        },
      }
  }
  override Str describe()
  {
    return "This is a Rule Description"
  }
  override Obj compile()
  {
    Tag[] tagsToReturn := [,]
    tagthing.eachSmartBox |box|
    {
      tagsToReturn.push(box.getTag())
    }
    return tagsToReturn
  }
}
