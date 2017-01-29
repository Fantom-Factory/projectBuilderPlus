/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using xml

class TemplateFactory
{


  static EquipTemplate getEquipTemplate(Equip eq, Str name, Str desc)
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

  static Template getTemplateFromXml(Obj template)
  {
    XElem? templateroot
    if(template.typeof == File#)
    {
    InStream tfin := template->in
    XDoc xdoc := XParser(tfin).parseDoc
    tfin.close
    templateroot = xdoc.root
    }
    else if(template.typeof == XElem#)
    {
      templateroot = template
    }

    Tag[] xtags := [,]
    templateroot.elems.each |elem|
    {
      xtags.push(Tag.fromXml(elem))
    }
    Str templatename := templateroot.get("name")
    Str templatedesc := templateroot.get("desc")
    switch(templateroot.get("type"))
    {
      case "pbpgui::SiteTemplate":
      return SiteTemplate{
        it.name = templatename
        it.desc = templatedesc
        it.tags = xtags
      }
      case "pbpgui::EquipTemplate":
      return EquipTemplate{
        it.name = templatename
        it.desc = templatedesc
        it.tags = xtags
      }
      case "pbpgui::PointTemplate":
      return PointTemplate{
        it.name = templatename
        it.desc = templatedesc
        it.tags = xtags
      }
      default:
      return Template{
        it.name = templatename
        it.desc = templatedesc
        it.tags = xtags
      }
    }
  }

}
