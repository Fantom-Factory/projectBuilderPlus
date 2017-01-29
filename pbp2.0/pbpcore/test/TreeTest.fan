/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


using haystack

class TreeTest : Test
{
  Void testTree()
  {
    Project test := Project("treeTest")
    Site newSite := RecordFactory.getSite
    Equip newEquip := RecordFactory.getEquip(newSite)
    Point newPoint := RecordFactory.getPoint(newSite, newEquip)
    Point newPoint2 := RecordFactory.getPoint(newSite, newEquip)
    Point newPoint3 := RecordFactory.getPoint(newSite, newEquip)
    Point newPoint4 := RecordFactory.getPoint(newSite, newEquip)
    test.add(newSite)
    test.add(newEquip)
    test.add(newPoint)
    test.add(newPoint2)
    test.add(newPoint3)
    test.add(newPoint4)
    RecordTree tree := RecordTree{parentproject = test; treename="SEPTree"}

    RecordTreeRule seprule1 := RecordTreeRule{
      rules = [WatchType{typetowatch = Site#}]
      parentref = null
    }
    RecordTreeRule seprule2 := RecordTreeRule{
      rules = [WatchType{typetowatch = Equip#}]
      parentref = RefTag{name="siteRef"; val=Ref.nullRef}
    }
    RecordTreeRule seprule3 := RecordTreeRule{
      rules = [WatchType{typetowatch = Point#}]
      parentref = RefTag{name="equipRef"; val=Ref.nullRef}
    }

    tree.rules.add(seprule1)
    tree.rules.add(seprule2)
    tree.rules.add(seprule3)

    tree.insert(newSite)
    tree.insert(newEquip)
    tree.insert(newPoint)
    tree.insert(newPoint2)
    tree.insert(newPoint3)
    tree.insert(newPoint4)
    echo(tree.roots)
    Env.cur.out.writeObj(tree.roots[0])
    //echo(tree.datamash)
    //Env.cur.out.writeObj(seprule1)
    //Env.cur.out.writeObj(seprule2)
    //Env.cur.out.writeObj(seprule3)
   // tree.roots.each |root|
    //{
      //Env.cur.out.writeObj(root)
    //}
    tree.save
    RecordTree opentree := RecordTree.fromFile(test.treeDir+`SEPTree.tree`,test)
    opentree.scanProject()
    echo(opentree.roots)
    //Env.cur.out.writeObj(tree)
    //add verifies here!! woohoooo

    RecordTree tree2 := RecordTree{parentproject = test; treename="Display_Names"}
    RecordTreeRule disrule1 := RecordTreeRule{
      rules = [WatchTags{tagstowatch = [StrTag{name="dis"; val=""}]}]
      parentref = null
    }
    tree2.rules.add(disrule1)
    tree2.save

  }

}

