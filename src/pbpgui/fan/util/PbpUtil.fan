/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using pbpcore

class PbpUtil
{

  static Menu makeRecTablePopup(PbpListener pbp, Event e, Map map)
  {
    Menu menu := Menu
    {
      MenuItem {
        text = "Refresh All";
        onAction.add |g| {
          Project curProject := pbp.callback("getCurProject")
          Str? makeNavNameFuncs := curProject.projectConfigProps.get("makeNavNameFunction")
          if (makeNavNameFuncs != null) {
            pbp.callback("runNavNameFunc", [makeNavNameFuncs, e])
          } else {
            UpdateRecordTable(e.widget, map).invoked(g)
          }
        }
      },
    }

    Map auxwidgets := pbp.callback("getAuxWidgets")
    if(auxwidgets.containsKey("addRecTablePopupItems"))
    {
      List menuItems := auxwidgets["addRecTablePopupItems"]
      menuItems.each |MenuItemWrapper item|
      {
        menu.add(item.getItem(e))
      }
      menu.relayout
    }
    return menu
  }

  static Menu makeRecTreePopup(PbpListener pbp, Event e)
  {
    Menu menu := Menu
    {
      MenuItem {
        text = "Refresh All";
        onAction.add|g|
        {
          UpdateTree(e.widget).invoke(g)
        }
      },
    }

    Map auxwidgets := pbp.callback("getAuxWidgets")
    if(auxwidgets.containsKey("addRecTreePopupItems"))
    {
      List menuItems := auxwidgets["addRecTreePopupItems"]
      menuItems.each |MenuItemWrapper item|
      {
        menu.add(item.getItem(e))
      }
      menu.relayout
    }
    return menu
  }

  static Tag[] getTagsFromInstruct(Instruction instruct)
  {
    Tag[] tags := [,]
    instruct.fieldWrapper.children.each | child|
    {
      item := child as SmartBox
      if(item != null)
      {
        tags.push(item.getTag)
      }
    }
    return tags
  }


  static Type? getTypeFromInstruct(Instruction instruct)
  {
    Combo combo := instruct.fieldWrapper.children.find |Widget w -> Bool| {return w.typeof == Combo#}
    Str selected := combo.selected
    switch(selected.lower)
    {
    case WatchId.ignore.lower:
    return Record#
    case WatchId.site.lower:
    return Site#
    case WatchId.equip.lower:
    return Equip#
    case WatchId.point.lower:
    return pbpcore::Point#
    default:
    return Record#
    }
  }

  static Str getNameFromType(Type? type)
  {
    switch(type.name.lower)
    {
    case "record":
    return "ignore"
    case "site":
    return "site"
    case "equip":
    return "equip"
    case "point":
    return "point"
    default:
    return "ignore"
    }
  }
}

