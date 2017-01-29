/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using xml

const class TemplatePack : Templateing
{
  const List[] templates := [,]

  new make(|This| f) : super(f)
  {
    f(this)
  }


  override XElem toXml()
  {
    XElem root := XElem("TemplatePack"){XAttr("name",this.name),XAttr("desc",this.desc),XAttr("type",this.typeof.toStr),}
    templates.each |tpack|
    {
      XElem innerroot := XElem("pack")
      tpack.each |template|
      {
        innerroot.add(template->toXml)
      }
      root.add(innerroot)
    }
    return root
  }



}
