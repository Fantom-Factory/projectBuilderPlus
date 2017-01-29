/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////



class ProjectTest : Test
{
  Void testProject()
  {
    verify(Project("testproj").name == "testproj") //Testing Constructor
    Project test := Project("test")
    Site newSite := RecordFactory.getSite
    Equip newEquip := RecordFactory.getEquip(newSite)
    Point newPoint := RecordFactory.getPoint(newSite, newEquip)

    newMap := test.dataMap.val->rw->add(newSite.id.toStr,newSite)->add(newEquip.id.toStr,newEquip)->add(newPoint.id.toStr,newPoint)
    test.dataMap.getAndSet(newMap.toImmutable)

    verify(test.get(newSite.id).typeof == Site#)
    //verify(test.get(newEquip.id) == newEquip)
   // verify(test.get(newPoint.id) == newPoint)
    //test.dataMap.getAndSet([:].toImmutable)

    test.add(newSite)
    test.add(newEquip)
    test.add(newPoint)


    //while(test.get(newSite.id)==null){}

    verify(test.get(newSite.id) == newSite)
    verify(test.get(newEquip.id) == newEquip)
    verify(test.get(newPoint.id) == newPoint)

    test.save()

  }

  Void testProjectFullDemo()
  {
    Project test := Project("test2")
    Site newSite := RecordFactory.getSite
    Equip newEquip := RecordFactory.getEquip(newSite)
    Point newPoint := RecordFactory.getPoint(newSite, newEquip)

    test.add(newSite)
    test.add(newEquip)
    test.add(newPoint)

    test.changeProc.send(Change{
      id=CID.ADDTAG;
      target=newSite.id;
      opts=[TagFactory.getTag("test","test")]
      })

    Int ticks := 0
    //while(test.get(newSite.id).get("test") == null){ticks++}
    echo(ticks)

    verify(test.get(newSite.id).get("test") != null)
}

  override Void teardown()
  {
    FileUtil.getProjectHomeDir("test").delete
    FileUtil.getProjectHomeDir("test2").delete
    FileUtil.getProjectHomeDir("testproj").delete
  }

}
