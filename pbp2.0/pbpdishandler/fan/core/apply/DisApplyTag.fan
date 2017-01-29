/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore
using pbpgui
using projectBuilder

@Serializable
class DisApplyTag : DisApply
{
  const Tag tagToFind

  @Transient
  ProjectBuilder? projectBuilder // is nullable, but never can be null


  new make(|This| f)
  {
    f(this)
  }

  override Tag apply(Record rec, Tag disTag)
  {
    Tag? tagToFind := rec.get(tagToFind.name)
    if(tagToFind==null){return disTag}
    else
    {
      if(disTag.val!="")
      {
        if(tagToFind.typeof==RefTag#)
        {
          parentrec := getRecordById(tagToFind.val.toStr)
          if (parentrec != null) return StrTag{name="dis"; val=disTag.val.toStr+"-"+parentrec.get("dis").val}
        }
        return StrTag{name="dis"; val=disTag.val.toStr+"-"+tagToFind.val.toStr}
      }
      else
      {
        if(tagToFind.typeof==RefTag#)
        {
          parentrec := getRecordById(tagToFind.val.toStr)
          if (parentrec != null) return StrTag{name="dis"; val=parentrec.get("dis").val}
        }
        return StrTag{name="dis"; val=tagToFind.val.toStr}
      }
    }
  }

  private Record? getRecordById(Str id)
  {
    return projectBuilder.prj?.database?.getById(id)
  }

  Tag getTag()
  {
    return tagToFind
  }

  override Str desc()
  {
    return "This will apply the value of tag: " + getTag().name + " to the display name"
  }
}
