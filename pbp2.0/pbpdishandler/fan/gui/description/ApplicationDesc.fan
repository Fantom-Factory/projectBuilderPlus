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

class ApplicationDesc : Description, Compilable
{
  private Str[] uservals
  private Tag[] tagvals
  private RuleHolder tagholder
  private UserValHolder userholder

  new make(Str[] uservals, Tag[] tagvals) : super()
  {
    this.uservals = uservals
    this.tagvals = tagvals
    tagholder = RuleHolder(this.tagvals)
    userholder = UserValHolder(uservals)
     top = Label{text=title; font=Font { bold = true }}
    center = body()
  }
  override Str title(){return "Applications"}
  override Widget body(){
    // ScrollPane swapped with ContentPane. Pane not removed because of all parent.parent.parent... stuff
    return ContentPane{
      TabPane{
      Tab{
      text="User Values"
      EdgePane{
      it.center = userholder
      },
      },
      Tab
      {
      text="Tag Values"
      EdgePane{
      it.center = tagholder
      },
      },
    },
    }
  }
  override Str describe()
  {
    return "This is a Application Description"
  }
  override Obj compile()
  {
    Str[] returnuser := [,]
    Tag[] returntag := [,]
    userholder.valholder.each |Text text|
    {
      returnuser.push(text.text)
    }
    tagholder.eachSmartBox |box|
    {
      returntag.push(box.getTag)
    }
    return [returnuser, returntag]
  }
}
