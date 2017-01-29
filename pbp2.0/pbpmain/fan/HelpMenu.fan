/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore
using pbpgui
using fwt
using gfx

class HelpMenu : Menu, UiUpdatable
{

   new make()
   {
      text=Main.updatesAvail.val?"Help (Updates Available)":"Help";
      add( MenuItem(UnitHelperCommand()))
      add( MenuItem(TimezoneHelperCommand()))
      add( MenuItem(MakeNewHelpdeskTicket()))
      add( MenuItem{it.mode=MenuItemMode.sep})
      add( MenuItem(OpenVersionControl()))
      add( MenuItem(Update()){
         it.enabled = Main.updatesAvail.val;
       })
      add( MenuItem{it.mode=MenuItemMode.sep})
      add( MenuItem(AboutCommand()))
  }

 override Void updateUi(Obj? params := null)
 {
   text=Main.updatesAvail.val?"Help (Updates Available)":"Help";
   children.find |MenuItem m -> Bool| { m.command is Update }.enabled = enabled = Main.updatesAvail.val;
   relayout
   parent.relayout
 }
}
