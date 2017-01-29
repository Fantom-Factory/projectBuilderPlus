/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using xml

class TagLib
{
  File? tagDir := FileUtil.getTagDir
  File? tagLibFile
  XElem? root
  Tag[] tags := [,]

  static TagLib fromXml(File taglibfile)
  {
    TagLib newtaglib := TagLib()
    newtaglib.tagLibFile = taglibfile
    InStream tagLibFileIn := taglibfile.in
    XDoc doc := XParser(tagLibFileIn).parseDoc
    newtaglib.root = doc.root
    newtaglib.root.children.each |child|
    {
      newtaglib.tags.push(Tag.fromXml(child))
    }
    tagLibFileIn.close
    newtaglib.tagDir = taglibfile.parent
    return newtaglib
  }

  Tag? getTag(Str name)
  {
    return tags.find|Tag t->Bool|{return t.name == name}
  }

  Void addTag(Tag tag)
  {
    search := tags.find |Tag t -> Bool| {return t.name == tag.name}
    if(search == null)
    {
      tags.push(tag)
    }
    return
  }

  Void write()
  {
      XElem root := XElem("taglib"){XAttr("version","2.0"),}
      tags.each |tag|
      {
        root.add(XElem(tag.name){XAttr("val",""), XAttr("kind", tag->kind),})
      }
      XDoc newdoc := XDoc(root)
      File taglibsave := tagLibFile
      OutStream taglibsaveout := taglibsave.out
      newdoc.write(taglibsaveout)
      taglibsaveout.close
  }

}
