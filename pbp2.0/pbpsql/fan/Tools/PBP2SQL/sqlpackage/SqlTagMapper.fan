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

class SqlTagMapper : SqlFormThingyBlob
{
  Tag tag
  AtomicRef listRef
  Str mapCol := ""
  Str dVal := ""
  Str rExp := ""
  //static const Image deleteCircle := Image(`fan::/icons/x16/circleDelete.png`)

  Button? deleteButton
  Label? tagLabel
  SqlColSelector? colSelector
  Text? defVal
  Text? regExp

  new make(Tag tag, AtomicRef listRef)
  {
    this.tag=tag
    this.listRef=listRef
  }

  override Widget[] getForm()
  {
    if(tag.typeof == Tag#)
    {
      tagLabel = Label{text=tag.name}
    }
    else
    {
      tagLabel = Label{text=tag.name+"<${tag->kind}>"}
    }
    colSelector = SqlColSelector(listRef){}
   //TODO defVal= Text{}
    regExp= Text{}
    //TODO: Place functionality of this Button in a Command class.
    deleteButton = Button{//image=deleteCircle;
    text="Delete"
    onAction.add|e|{
      removeForm
      }}
    widgets := [deleteButton, tagLabel, colSelector, /*TODO defVal,*/ regExp]
    return widgets
  }

  override Void removeForm()
  {
     Widget parentWidget := deleteButton.parent
     parentWidget.remove(deleteButton)
     parentWidget.remove(tagLabel)
     parentWidget.remove(colSelector)
    //TODO parentWidget.remove(defVal)
     parentWidget.remove(regExp)
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
    if(colSelector.text != "")
    {
    Str tagId := Uuid().toStr
    Str:Str colmap := [:]
    Str:SqlFilter filtermap := [:]
    Str:Tag[] tagmap := [:]
    //if(defVal.text != "")
    if(regExp.text != "")
    {
      filtermap.add(tagId, SqlRegexFilter(regExp.text))
    }
    tagmap.add(tagId,[tag])
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
