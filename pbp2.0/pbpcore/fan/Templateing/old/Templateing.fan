/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using xml

const class Templateing
{
  const Str name
  const Str desc

  new make(|This| f) {f(this)}

  static Templateing? fromXml(Obj template)
  {
    switch(template.typeof)
    {
    case Template#:
    return TemplateFactory.getTemplateFromXml(template)
    case TemplatePack#:
    return TemplatePackFactory.getTemplatePackFromXml(template)
    default:
    return null
    }
  }

  virtual XElem toXml()
  {
    return this->toXml
  }

}
