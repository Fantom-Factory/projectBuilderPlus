/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using haystack

class RecordTest : Test
{
  Void testRecord()
  {
    Ref test := Ref.gen
    Record newRec := Record{
      data =[,]
      it.id = test
   }

    verify(newRec.id == test)
    verify(newRec.set(TagFactory.getTag("test","test")).typeof == Record#)
    verify(newRec.set(TagFactory.getTag("test","test")).get("test").val == "test")
    verify(newRec.set(TagFactory.getTag("test","notest")).typeof == Record#)
    verify(newRec.set(TagFactory.getTag("test","notest")).get("test").val == "notest")
    verify(newRec.set(TagFactory.getTag("test","notest")).remove("test").get("test") == null)


  }

  Void testRecordFactory()
  {
    Site newSite := RecordFactory.getSite
    Equip newEquip := RecordFactory.getEquip(newSite)
    Point newPoint := RecordFactory.getPoint(newSite, newEquip)

    verify(newSite.id.typeof == haystack::Ref#)
    verify(newEquip.id.typeof == haystack::Ref#)
    verify(newPoint.id.typeof == haystack::Ref#)

    verify(newEquip.data.find |Obj? obj -> Bool| {obj->name == "siteRef"}.val == newSite.id)
    verify(newPoint.data.find |Obj? obj -> Bool| {obj->name == "siteRef"}.val == newSite.id)
    verify(newPoint.data.find |Obj? obj -> Bool| {obj->name == "equipRef"}.val == newEquip.id)

    verify(newEquip.get("siteRef").val == newSite.id)
    verify(newPoint.get("siteRef").val == newSite.id)
    verify(newPoint.get("equipRef").val == newEquip.id)

     verify(newSite.set(TagFactory.getTag("test","test")).typeof == Site#)
     verify(newEquip.set(TagFactory.getTag("test","test")).typeof == Equip#)
     verify(newPoint.set(TagFactory.getTag("test","test")).typeof == Point#)

  }

  Void testToAndFromXml()
  {
    verify(Project("testproj").name == "testproj") //Testing Constructor
    Project test := Project("test")
    Site newSite := RecordFactory.getSite
    Equip newEquip := RecordFactory.getEquip(newSite)
    Point newPoint := RecordFactory.getPoint(newSite, newEquip)


    test.add(newSite)
    test.add(newEquip)
    test.add(newPoint)
/*
    Int ticks := 0
    while(test.get(newSite.id)==null){ticks++}
    echo(ticks)
*/

    verify(test.get(newSite.id) == newSite)
    verify(test.get(newEquip.id) == newEquip)
    verify(test.get(newPoint.id) == newPoint)

    test.save()

    Site? newSite2
    Equip? newEquip2
    Point? newPoint2
    test.database.getClassMap(Site#).vals.each |rec|
    {
      newSite2 = rec
    }

    test.database.getClassMap(Equip#).vals.each |rec|
    {
      newEquip2 = rec
    }

   test.database.getClassMap(Point#).vals.each |rec|
    {
      newPoint2 = rec
    }

    newSite2.data.each |tag,index|
    {
      verify( tag.val.toStr == newSite.data[index].val.toStr)
    }

    newEquip2.data.each |tag,index|
    {
     verify( tag.val.toStr == newEquip.data[index].val.toStr)
    }

    newPoint2.data.each |tag,index|
    {
     verify( tag.val.toStr == newPoint.data[index].val.toStr)
    }
  }

  override Void teardown()
  {
    //FileUtil.getProjectHomeDir("test").delete
    FileUtil.getProjectHomeDir("testproj").delete
  }

}
