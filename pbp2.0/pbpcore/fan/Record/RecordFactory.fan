/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using xml
using haystack

class RecordFactory
{
  static Site getSite()
  {
    Site newSite := Site
    {
      data = [
        TagFactory.getTag("dis","New Site"),
        TagFactory.getTag("tz",""),
        TagFactory.getTag("geoAddr",""),
        TagFactory.getTag("area",""),
        TagFactory.getTag("weatherRef",Ref.nullRef),
        TagFactory.getTag("site",Marker.fromStr("site"))
        ]
    }
    return newSite
  }

  static Equip getEquip(Record? parentSite := null)
  {
    Equip newEquip := Equip
    {
      data = [
        TagFactory.getTag("dis","New Equip"),
        TagFactory.getTag("siteRef",Ref.nullRef),
        TagFactory.getTag("equip",Marker.fromStr("equip"))
        ]
    }
    if(parentSite!= null)
    {
      newEquip = Equip
      {
        data = [
          TagFactory.getTag("dis", "" + parentSite.get("dis").val + " - " + "New Equip"),
          TagFactory.getTag("siteRef",parentSite.id),
          TagFactory.getTag("equip",Marker.fromStr("equip"))
          ]
      }
    }
    return newEquip
  }

  static Point getPoint(Record? parentSite := null, Record? parentEquip := null)
  {
    Point newPoint := Point
    {
      data = [
        TagFactory.getTag("dis","New Point"),
        TagFactory.getTag("unit",""),
        TagFactory.getTag("tz",""),
        TagFactory.getTag("kind",""),
        TagFactory.getTag("his",Marker.fromStr("his")),
        TagFactory.getTag("equipRef",Ref.nullRef),
        TagFactory.getTag("siteRef",Ref.nullRef),
        TagFactory.getTag("point",Marker.fromStr("point"))
        ]
    }
    if(parentSite!= null && parentEquip!= null)
    {
      newPoint = Point
      {
        data = [
        TagFactory.getTag("dis", "" + parentEquip.get("dis").val + " - " + "New Point"),
        TagFactory.getTag("unit",""),
        TagFactory.getTag("tz",parentSite.get("tz").val),
        TagFactory.getTag("kind",""),
        TagFactory.getTag("his",Marker.fromStr("his")),
        TagFactory.getTag("equipRef", parentEquip.id),
        TagFactory.getTag("siteRef", parentSite.id),
        TagFactory.getTag("point",Marker.fromStr("point"))
        ]
      }
    }
    return newPoint
  }


   @Transient
    static Record getRecFromXml(File xdoc)
      {
        Str ext := xdoc.ext
        InStream xdocin := xdoc.in
        XDoc newdoc := XParser(xdocin).parseDoc
        xdocin.close

        XElem root := newdoc.root
        Tag[] data := Tag[,]
        root.elems.each |elem|
        {
          data.push(Tag.fromXml(elem))
        }
        Tag id := data.find |Tag t->Bool| {return t.name == "id"}
        data.remove(id)
        switch(ext)
        {
          case "site":
            return Site{it.id = id.val; it.data = data}
          case "equip":
            return Equip{it.id = id.val; it.data = data}
          case "point":
           return Point{it.id = id.val; it.data = data}
          default:
           return Record{it.id = id.val; it.data = data}
        }

      }

      static Record replicateFromTemplateRec(TemplateRecord record, Str newrecid)
      {
        Type rectype := record.baseType
        switch(rectype)
        {
          case Site#:
            return Site{
                data=record.data
                id=Ref.fromStr(newrecid)
              }
          case Equip#:
            return Equip{
                data=record.data
                id=Ref.fromStr(newrecid)
              }
          case Point#:
            return Point{
                data=record.data
                id=Ref.fromStr(newrecid)
              }
          default:
            return Record{
                data=record.data
                id=Ref.fromStr(newrecid)
              }
        }
      }

      static Record recordFromTemplateRec(TemplateRecord record)
      {
        Type rectype := record.baseType
        switch(rectype)
        {
          case Site#:
            return Site{
                data=record.data
                id=record.id
              }
          case Equip#:
            return Equip{
                data=record.data
                id=record.id
              }
          case Point#:
            return Point{
                data=record.data
                id=record.id
              }
          default:
            return Record{
                data=record.data
                id=record.id
              }
        }
      }

      static Record getRecByType(Type type)
      {
        switch(type)
        {
          case Site#:
            return getSite()
          case Equip#:
            return getEquip()
          case Point#:
            return getPoint()
          default:
            return Record{data=[StrTag{name="dis"; val="New Record"}]}
        }
      }

      static Tag[] getCombinedData(Record[] recs)
      {
        Str:Tag tags := [:]
        Str:Int tagCounter := [:]
        recs.each |rec|
        {
          rec.data.each |tag|
          {
            if(!tags.containsKey(tag.name) && tag.name!="id" && tag.name!="dis")
            {
              tags.add(tag.name,TagFactory.getBlankVal(tag))
              tagCounter.add(tag.name,1)
            }
            else if(tags.containsKey(tag.name))
            {
              tagCounter[tag.name] = tagCounter[tag.name].increment
            }
          }
        }
        Tag[] tagCheck := tags.findAll |list, tagname ->Bool| {return tagCounter[tagname]==recs.size}.vals
        return tagCheck
      }
}
