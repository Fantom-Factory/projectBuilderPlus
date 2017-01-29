/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using xml

class TemplatePackFactory
{

/*
   static EquipTemplate getEquipTemplatePack(List[] templates, Str name, Str desc)
  {
    Equip base := RecordFactory.getEquip
    eq.data.each |t|
    {
      base.add(t)
    }
    return EquipTemplate{
      it.name = name
      it.desc = desc
      it.tags = base.data
    }
  }

  static PointTemplate getPointTemplate(Point pt, Str name, Str desc)
  {
    Point base := RecordFactory.getPoint
    pt.data.each |t|
    {
      base.add(t)
    }
    return PointTemplate{
      it.name = name
      it.desc = desc
      it.tags = base.data
    }
  }

  static SiteTemplate getSiteTemplate(Site st, Str name, Str desc)
  {
    Site base := RecordFactory.getSite
    st.data.each |t|
    {
      base.add(t)
    }
    return SiteTemplate{
      it.name = name
      it.desc = desc
      it.tags = base.data
    }
  }
*/

  static TemplatePack getTemplatePackFromXml(Obj tpack)
  {
    XElem? tpackroot := null
    if(tpack.typeof == File#)
    {
    InStream tfin := tpack->in
    XDoc xdoc := XParser(tfin).parseDoc
    tfin.close
    tpackroot = xdoc.root
    }
    else if(tpack.typeof == XElem#)
    {
      tpackroot = tpack
    }

    List[] xtemps := [,]
    tpackroot.elems.each |elem|
    {
      List temps := [,]
      elem.elems.each |template|
      {
        temps.push(Template.fromXml(template))
      }
      xtemps.push(temps)
    }
    Str templatename := tpackroot.get("name")
    Str templatedesc := tpackroot.get("desc")
    switch(tpackroot.get("type"))
    {
      case "pbpgui::SiteTemplatePack":
      return SiteTemplatePack{
        it.name = templatename
        it.desc = templatedesc
        it.templates = xtemps
      }
      case "pbpgui::EquipTemplatePack":
      return EquipTemplatePack{
        it.name = templatename
        it.desc = templatedesc
        it.templates = xtemps
      }
      case "pbpgui::PointTemplatePack":
      return PointTemplatePack{
        it.name = templatename
        it.desc = templatedesc
        it.templates = xtemps
      }
      default:
      return TemplatePack{
        it.name = templatename
        it.desc = templatedesc
        it.templates = xtemps
      }
    }
  }


}

