/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore
using concurrent
using pbpgui
using fwt
using gfx

class SqlRegExRule : SqlFormThingyBlob
{
  Tag[] tags
  AtomicRef listRef

  //static const Image deleteCircle := Image(`fan::/icons/x16/circleDelete.png`)

  Button? deleteButton
  Label? tagLabel
  SqlColSelector? colSelector
  Text? regExp
  Combo? tagsDisplay
  Button? addTagsButton
  new make(Tag[] tags, AtomicRef listRef)
  {
    this.tags=tags
    this.listRef=listRef
  }

  override Widget[] getForm()
  {
    colSelector = SqlColSelector(listRef)
    regExp= Text{}
    tagsDisplay = Combo{
      items=tags//.toStr
      onModify.add|e|{
        e.widget.relayout
        e.widget.parent.relayout
      }
    }
    deleteButton = Button{//image=deleteCircle;
      text="Delete"
      onAction.add|e|{
        removeForm
      }}
    addTagsButton = Button( AddTagsToRuleCommand(this))

    widgets := [deleteButton, colSelector, regExp, tagsDisplay, addTagsButton]
    return widgets
  }

  override Void removeForm()
  {
     Widget parentWidget := deleteButton.parent
     parentWidget.remove(deleteButton)
     parentWidget.remove(colSelector)
     parentWidget.remove(regExp)
     parentWidget.remove(tagsDisplay)
     parentWidget.remove(addTagsButton)
     parentWidget.relayout
     parentWidget.parent.relayout
     parentWidget.parent.parent.relayout
     parentWidget.parent.parent.parent.relayout
  }

  Regex? getRegEx()
  {
    if(regExp!=null &&regExp.text!="")
    {
      return Regex.fromStr(regExp.text)
    }
    else
    {
      return null
    }
  }

override SqlPackageRule? processRule()
  {
    if(colSelector.text!="")
    {
    Str:Str colmap := [:]
    Str:SqlFilter filtermap := [:]
    Str:Tag[] tagmap := [:]
    //if(defVal.text != "")
    Str tagId := Uuid().toStr
    if(regExp.text != "")
    {
      filtermap.add(tagId, SqlRegexFilter(regExp.text))
    }
    tagmap.add(tagId,tags)
    colmap.add(colSelector.text, tagId)
    return SqlPackageRule{
      specialRules =[,]
      mapping = colmap
      filter = filtermap
      it.tagmap = tagmap
    }
    }
    else
    {
     return null
    }
  }
}
