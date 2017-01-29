/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
class BuilderTest : Test
{
  Void testBuilder()
  {

    Builder test := Builder()
    //test._recordTabs.add(Tab{ text = "Explorer"; ProjectExplorer, })
    //test._recordTabs.add(Tab{ text = "Sites"; RecordExplorer, })
    //test._recordTabs.add(Tab{ text = "Equips"; RecordExplorer, })
    //test._recordTabs.add(Tab{ text = "Points"; RecordExplorer, })
    ToolBarTree tbtree := ToolBarTree{tree=Tree(); toolbar=ToolBarLeftRight();}
    test._treeTabs.add(Tab{text="test1"; tbtree,})
    tbtree.toolbar.add(Button{image=Image(`fan://icons/x16/refresh.png`)})
    test.open

  }

}
