/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////



class MiscTest : Test
{
 Void testPbpWriter()
 {
    Project test := Project("pbptest")
    Site newSite := RecordFactory.getSite
    Equip newEquip := RecordFactory.getEquip(newSite)
    Point newPoint := RecordFactory.getPoint(newSite, newEquip)

    test.add(newSite)
    test.add(newEquip)
    test.add(newPoint)
    test.save()

    //PbpWriter(test).compile()
 }

}
