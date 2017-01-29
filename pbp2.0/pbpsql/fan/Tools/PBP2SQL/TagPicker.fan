/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore
using pbpgui

class TagPicker : PbpWindow
{
//TODO: Fill in implementation!
 EdgePane mainWrapper := EdgePane{}
 ButtonGrid buttonGrid := ButtonGrid{Button(Dialog.ok),}
 TabPane centerWrapper := TabPane{}

 new make(Window? parentWindow) : super(parentWindow){}

 override Obj? open()
 {
   TagExplorer standardTagexp := TagExplorer(FileUtil.getTagDir+`standard.taglib`, null, true)

   centerWrapper.add(Tab{text="Standard"; standardTagexp,})
   mainWrapper.center = centerWrapper
   mainWrapper.bottom = buttonGrid
   content=mainWrapper
   super.open()

   return standardTagexp.getSelected
 }

/*
//TODO: Fill in implementation!
    coreWidgets[customTagsExpHandle] = TagExplorer{
       tagToolbar = GridPane{ numCols = 2; TagCommands(this).getToolbar, TagUtil(this).getTagLibCombo,}
       tagTable = Table()
       tagTableModel = TagTableModel(FileUtil.getTagDir.listFiles.find|File f->Bool|{return f.ext=="taglib"})
       //addToProjectButton = Button(AddTagToRecord(this,it.tagTable))
     }
    builder._tagTabs.add(Tab{ text="Standard Tags"; coreWidgets[standardTagsExpHandle],})
    builder._tagTabs.add(Tab{ text="Custom Tags"; coreWidgets[customTagsExpHandle],})
*/

//coreWidgets[standardTagsExpHandle]->setTableModel(TagTableModel(FileUtil.getTagDir+`standard.taglib`))

}
