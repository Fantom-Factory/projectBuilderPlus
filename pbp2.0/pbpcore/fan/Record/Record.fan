/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using haystack
using xml

@Serializable
const class Record
{
  
  const Tag[] data := [,]
  const Ref id := Ref.gen
    
  new make(|This| f) {
    f(this)
    if(data.find |Tag t -> Bool| {return t.name == "id"} == null)
    {
      data = [,].addAll(data).add(TagFactory.getTag("id",id))
    }
  }
  
  virtual Tag? get(Str name) {
    return this.data.find |Tag tag -> Bool| {tag.name == name}
  }

  Record set(Tag? moddedTag) {
    return RecUtil.modRec(this, moddedTag.name, moddedTag)
  }

  Record add(Tag newTag) {
    return RecUtil.modRec(this, newTag.name, newTag)
  }

  Record? addAll(Tag[] newTags) {
    Record newRec := this
    newTags.each |tag|
    {
      newRec = newRec.add(tag)
    }
    return newRec
  }

  Record removeTags(Str[] tagNames) {
    return RecUtil.removeTags(this, tagNames)
  }

  Record remove(Str killName) {
    return RecUtil.removeTags(this, [killName])
  }

  XElem toXml()
  {
    recordRoot := XElem("record") {XAttr("id", this.id.toStr),}
    data.each |tag|
    {
      recordRoot.add(tag.toXml)
    }
    return recordRoot
  }

  static Record fromFile(File file)
  {
    return file.readObj
  }

  Dict getDict()
  {
    Str:Obj? dataMap := Str:Obj?[:]
    data.each |tag|
    {
      if(tag.typeof == MarkerTag#)
      {
        dataMap.add(tag.name,Marker.fromStr(tag.name))
      }
      else if(tag.typeof == NumTag#)
      {
        dataMap.add(tag.name,tag.val.toStr)
      }
      else if(tag.typeof == StrTag#)
      {
        dataMap.add(tag.name, tag.val.toStr)
      }
      else
      {
        dataMap.add(tag.name,tag.val)
      }
    }
    return Etc.makeDict(dataMap)
  }

  override Str toStr()
  {
    "Record "+get("dis")
  }
}
