/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore
using concurrent

class ManageTrees : Command
{
  private PbpListener pbp
  new make(PbpListener pbp) : super.makeLocale(Pod.find("projectBuilder"), "manageTrees")
  {
    this.pbp =pbp
  }
  override Void invoked(Event? e)
  {
    prj := pbp.prj
    Builder builder := pbp.getBuilder
    if(prj!=null)
    {
      TreeManagerWindow(e.window, pbp, TreeSelectorTableModel(FileUtil.envTreeDir), builder._treeTabs).open
    }
  }
}

class AddRecordTreeLayer : Command
{
  private Wizard wizard
  new make(Wizard wizard) : super.makeLocale(Pod.find("projectBuilder"), "addLayer")
  {
    this.wizard = wizard
  }

  override Void invoked(Event? e)
  {
    Instruction[] basics :=
      [
        Instruction("Must have these tags:", WatchId.have),
        Instruction("Must have these tags with these values:", WatchId.haveVal),
        Instruction("Must not have these tags:", WatchId.haveNot),
        Instruction("You can find the parent reference from this tag:", WatchId.parentRef),
        Instruction("Must be this type of Record:", WatchId.isType).addField(Combo{items=["ignore","site","equip","point"]})
      ]
    InstructionBox newlayer := InstructionBox("New Layer", basics)
    wizard.addBox(newlayer)
  }


}

** New tree templae
class NewTreeFunction : Command
{
  private PbpListener pbp
  private Table? table

  new make(PbpListener pbp, Table? table) : super.makeLocale(Pod.find("projectBuilder"), "newTreeCmd")
  {
    this.pbp = pbp
    this.table = table
  }
  override Void invoked(Event? e)
  {
    prj := pbp.prj
    PbpWorkspace ws := pbp.workspace
    Bool save :=false
    Instruction[] basics :=
      [
        Instruction("Must have these tags:", WatchId.have),
        Instruction("Must have these tags with these values:", WatchId.haveVal),
        Instruction("Must not have these tags:", WatchId.haveNot),
        Instruction("You can find the parent reference from this tag:", WatchId.parentRef),
        Instruction("Must be this type of Record:", WatchId.isType).addField(Combo{items=["ignore","site","equip","point"]})
      ]
      InstructionBox root := InstructionBox("Root", basics)
      Wizard wiz := Wizard(e.window){
        boxes = [root]

        it.tagExp = TagExplorer.makeWithCombo(
            FileUtil.getTagDir+`standard.taglib`,
            TemplateAddTag(it),
            TagUtil().getTagLibCombo,
            true)
      }

     wiz.nameText = Text{text="New Record Tree"}
     wiz.leftWrapper.top = EdgePane{
       bottom=ToolBar{Button(AddRecordTreeLayer(wiz)),}
       top=GridPane{numCols=2; Label{text="Name: "}, wiz.nameText,}
       }
     wiz.leftWrapper.bottom = ButtonGrid{
       numCols=2;
       Button{text="Save"; onAction.add|g|{save=true; g.window.close}},
       Button{text="Close"; onAction.add|g|{g.window.close}},
       }
     wiz.onClose.add |g|
     {
       if(save)
       {
         Wizard wiza := g.widget
         RecordTree recordTree := TreeUtil.interpretTree(wiza)
         recordTree.save(FileUtil.envTreeDir)

         (table.model as TreeSelectorTableModel).update
         table.refreshAll
     }
     }
     wiz.open
  }
}

** Edit tree templae
class EditTreeFunction : Command
{
  private PbpListener pbp
  private Table? table

  new make(PbpListener pbp, Table? table) : super.makeLocale(Pod.find("projectBuilder"), "editTreeCmd")
  {
    this.pbp = pbp
    this.table = table
  }
  override Void invoked(Event? e)
  {
    prj := pbp.prj
    PbpWorkspace ws := pbp.workspace
    tabs := (pbp.getBuilder as Builder)._treeTabs
    if(table == null && tabs.selected == null)
      return
    name :=  table != null ? table.model.text(0, table.selected.first)
      :  tabs.selected.text
    Bool save :=false

    Wizard wiz := Wizard(e.window){
      boxes = [,]

      it.tagExp = TagExplorer.makeWithCombo(
        FileUtil.getTagDir+`standard.taglib`,
        TemplateAddTag(it),
        TagUtil().getTagLibCombo,
        true)
    }

     wiz.nameText = Text{text="New Record Tree"}
     wiz.leftWrapper.top = EdgePane{
       bottom=ToolBar{Button(AddRecordTreeLayer(wiz)),}
       top=GridPane{numCols=2; Label{text="Name: "}, wiz.nameText,}
       }
     wiz.leftWrapper.bottom = ButtonGrid{
       numCols=2;
       Button{text="Save"; onAction.add|g|{save=true; g.window.close}},
       Button{text="Close"; onAction.add|g|{g.window.close}},
       }
     wiz.onClose.add |g|
     {
       if(save)
       {
         Wizard wiza := g.widget
         RecordTree recordTree := TreeUtil.interpretTree(wiza)
         recordTree.save(FileUtil.envTreeDir)
         (table.model as TreeSelectorTableModel).update
         table.refreshAll
       }
     }

      // populate with tree
     tree := RecordTree.fromFile(FileUtil.envTreeDir + `${name}.tree`, prj)

     wiz.nameText.text = tree.treename

     tree.rules.each |rules|
     {
       Combo combo := Combo{items=["ignore","site","equip","point"]}
       Instruction[] basics :=
       [
         Instruction("Must have these tags:", WatchId.have),
         Instruction("Must have these tags with these values:", WatchId.haveVal),
         Instruction("Must not have these tags:", WatchId.haveNot),
         Instruction("You can find the parent reference from this tag:", WatchId.parentRef),
         Instruction("Must be this type of Record:", WatchId.isType).addField(combo)
       ]

       wiz.boxes.add(InstructionBox(rules.name, basics))

       rules.watchTags?.tagstowatch?.each
       {
        basics[0].addField(InstructionSmartBox(it))
       }

       rules.watchVals?.tagstowatch?.each
       {
        basics[1].addField(InstructionSmartBox(it))
       }

       rules.watchTagsExclude?.tagstowatch?.each
       {
        basics[2].addField(InstructionSmartBox(it))
       }

       if(rules.parentref != null)
        basics[3].addField(InstructionSmartBox(rules.parentref))

       if(rules.watchTypes?.typetowatch != null)
       {
        nm := PbpUtil.getNameFromType(rules.watchTypes.typetowatch)
        combo.selectedIndex = combo.index(nm)
       }
     }

     wiz.open
  }
}

** Add tree to project
class AddTreeFunction : Command
{
  private PbpListener pbp
  private Table table

  new make(PbpListener pbp, Table table) : super.makeLocale(Pod.find("projectBuilder"), "addTreeCmd")
  {
    this.pbp = pbp
    this.table = table
  }

  override Void invoked(Event? e)
  {
    prj := pbp.prj
    Builder builder := pbp.getBuilder
    PbpWorkspace ws := pbp.workspace
    tabs := builder._treeTabs
    name := table.model.text(0, table.selected.first)

    File? recordTreeFile := FileUtil.envTreeDir + `${name}.tree`
    if(recordTreeFile != null)
    {
       recordTreeFile.copyInto(prj.treeDir)
       prj.rectrees.push(RecordTree.fromFile(recordTreeFile, prj))
       tree := prj.rectrees.peek
       treewidget := TreeWidget(pbp, tree)
       builder._treeTabs.add(Tab{ text=name; treewidget,})
     }
  }
}

class DeleteFromTree : Command
{
  private PbpListener pbp
  private Tree recTree
  new make(Tree recTree, PbpListener pbp) : super.makeLocale(Pod.find("projectBuilder"), "delTemplateRecord")
  {
    this.recTree = recTree
    this.pbp = pbp
  }

  override Void invoked(Event? e)
  {
    prj := pbp.prj
    PbpWorkspace pbpwkspace := pbp.workspace
    Str[] deletions := [,]
    recTree.selected.each |node|
    {
      deletions.addAll((recTree.model as RecordTreeModel).tree.recursiveDel((node as RecordTreeNode).record))
    }
    resp := Dialog.openWarn(e.window, "Are you sure you would like to delete ${deletions.size} from project ${prj}",null,Dialog.yesNo)
    if(resp==Dialog.yes)
    {
      Record[] todelete := [,]
      deletions.each |del|
      {
        Record? rec := prj.database.getById(del)
        if(rec!=null)
        {
          todelete.push(rec)
        }
      }

       ActorPool newPool := ActorPool()
       ProgressWindow pwindow := ProgressWindow(e.window, newPool)
       DatabaseThread dbthread := prj.database.getSyncThreadSafe(todelete.size, pwindow.phandler, newPool)
       todelete.each |rec|
       {
         dbthread.send([DatabaseThread.REMOVE, rec])
       }
      pwindow.open()
      newPool.stop()
      newPool.join()
      prj.database.unlock()
      pbpwkspace.siteExplorer.update(prj.database.getClassMap(Site#))
      pbpwkspace.equipExplorer.update(prj.database.getClassMap(Equip#))
      pbpwkspace.pointExplorer.update(prj.database.getClassMap(pbpcore::Point#))
      pbpwkspace.siteExplorer.refreshAll
      pbpwkspace.equipExplorer.refreshAll
      pbpwkspace.pointExplorer.refreshAll
      //recTree.refreshAll
    }
  }
}

** Remove tree from project
class RemoveTreeFunction : Command
{
  private PbpListener pbp
  private Table? table

  new make(PbpListener pbp, Table? table) :
    super.makeLocale(Pod.find("projectBuilder"), "removeTreeCmd")
  {
    this.pbp = pbp
    this.table = table
  }

  override Void invoked(Event? e)
  {
    prj := pbp.prj
    tabs := (pbp.getBuilder as Builder)._treeTabs
    trees := [,]
    name :=  table != null ? table.model.text(0, table.selected.first)
      :  tabs.selected.text
    result := Dialog.openMsgBox(Pod.find("projectBuilder"), "removeTreeCmd",
    e.window,
    "Do you want to remove $name ?",
    Dialog.okCancel)
    if(result == Dialog.ok)
    {
        f:= FileUtil.getTreeDir(prj.name) + `${name}.tree`
        f.delete
        tabs.tabs.each
        {
          if(it.text == name)
           tabs.remove(it)
        }
     }
  }
}

 ** Delete the tree template
class DeleteTreeFunction : Command
{
  private PbpListener pbp
  private Table? table

  new make(PbpListener pbp, Table? table) :
    super.makeLocale(Pod.find("projectBuilder"), "deleteTreeCmd")
  {
    this.pbp = pbp
    this.table = table
  }

  override Void invoked(Event? e)
  {
    prj := pbp.prj
    trees := [,]
    name := table.model.text(0, table.selected.first)
    result := Dialog.openMsgBox(Pod.find("projectBuilder"), "deleteTreeCmd",
    e.window,
    "Do you want to delete $name ?",
    Dialog.okCancel)
    if(result == Dialog.ok)
    {
        f:= FileUtil.envTreeDir + `${name}.tree`
        f.delete
        (table.model as TreeSelectorTableModel).update
        table.refreshAll
    }
  }
}


