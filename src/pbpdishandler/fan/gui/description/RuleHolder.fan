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

class RuleHolder : SashPane
{
  private GridPane tagHolder := GridPane{}
  private TagExplorer tagExplorer

  new make(Tag[] tags) : super()
  {
    weights = [501,314]
    add(
        ContentPane() { ScrollPane{tagHolder,}, }
    )
    add(tagExplorer = TagExplorer.makeWithCombo(
        FileUtil.getTagDir.listFiles.find|File f->Bool|{return f.ext=="taglib"},
        Command.makeLocale(Pod.of(this), "addTag", |Event event| { onAddToProjectClicked(event) }),
        TagUtil().getTagLibCombo,
        true)
    )

   tags.each |tag|
           {
             tagHolder.add(SmartBox(tag){
                 deleteButton.onAction.add |g|
                 {
                   onDeleteClicked(g)
                 }
             })
           }
  }
  
  private Void onDeleteClicked(Event g)
  {
    Widget smartbox := g.widget.parent
    smartbox.parent.remove(smartbox)

    this.parent.relayout
    this.parent.parent.relayout
    this.parent.parent.parent.relayout
    this.parent.parent.parent.parent.relayout
    this.parent.parent.parent.parent.parent.relayout

    tagHolder.relayout
    tagHolder.parent.relayout
    tagHolder.parent.parent.relayout
    tagHolder.parent.parent.parent.relayout
    this.repaint
  }
  
  private Void onAddToProjectClicked(Event e)
  {
    tagExplorer.getSelected.each |tag|
    {
      tagHolder.add(SmartBox(tag){
        deleteButton.onAction.add |g|
        {
          onDeleteClicked(g)
        }
      })
    }
    tagHolder.relayout
    tagHolder.parent.relayout
    tagHolder.parent.parent.relayout
    tagHolder.parent.parent.parent.relayout
  }

  Void eachSmartBox(|SmartBox w, Int i| f)
  {
    tagHolder.each |Widget w, Int i|
    {
        if (w is SmartBox) f(w, i)
    }
  }
}
