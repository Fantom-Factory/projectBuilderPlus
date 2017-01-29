/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


using xml

class TemplateLib
{
  File? templateDir
  File? templateLibFile
  XElem? root
  Templateing[] templates := [,]

  static TemplateLib fromXml(File templatelibfile)
  {
    TemplateLib newTemplatelib := TemplateLib()
    newTemplatelib.templateLibFile = templatelibfile
    InStream templatelibfilein := templatelibfile.in
    XDoc doc := XParser(templatelibfilein).parseDoc
    newTemplatelib.root = doc.root
    newTemplatelib.root.children.each |child|
    {
      newTemplatelib.templates.push(Templateing.fromXml(child))
    }
    templatelibfilein.close
    newTemplatelib.templateDir = templatelibfile.parent
    return newTemplatelib
  }

  Templateing? getTemplateing(Str name)
  {
    return templates.find|Templateing t->Bool|{return t.name == name}
  }

  Void addTemplateing(Templateing templateing)
  {
    search := templates.find |Templateing t -> Bool| {return t.name == templateing.name}
    if(search == null)
    {
      templates.push(templateing)
    }
    return
  }

  Void write()
  {
      XElem root := XElem("templatelib"){XAttr("version","1.0"),}
      templates.each |template|
      {
        root.add(template.toXml)
      }
      XDoc newdoc := XDoc(root)
      File templatelibsave := templateLibFile
      OutStream templatelibsaveout := templatelibsave.out
      newdoc.write(templatelibsaveout)
      templatelibsaveout.close
  }

}

