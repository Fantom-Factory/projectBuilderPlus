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

//TODO: Need to add stronger type strength? Maybe not because these commands are administered by me.

class TemplateCommands : Commands
{
  private PbpListener pbp

  new make(PbpListener pbp)
  {
    this.pbp = pbp
  }

  override ToolBar getToolbar()
  {
    ToolBar toolbar := ToolBar{}
    toolbar.addCommand(NewTemplateType(pbp))
    toolbar.addCommand(DeleteTemplateTypeFile())
    toolbar.addCommand(EditTemplateType(pbp))
    return toolbar
  }

  ToolBar getTemplateToolbar()
  {
    ToolBar toolbar := ToolBar{}
    toolbar.addCommand(NewTemplate(pbp))
    toolbar.addCommand(DeleteTemplate())
    toolbar.addCommand(EditTemplate(pbp))
    return toolbar
  }

}
class DeployTemplate : Command
{
  private PbpListener pbp
  new make(PbpListener pbp):super.makeLocale(Pod.find("projectBuilder"), "deployTemplate")
  {
    this.pbp = pbp
  }

  override Void invoked(Event? e)
  {
    prj := pbp.prj
    PbpWorkspace pbpwrapper := pbp.workspace
    TemplateExplorer tempExp := e.widget.parent
    File[] template := tempExp.getSelected
    if(template.size > 0)
    {
      Template realTemplate := File(template.first.uri).readObj

      TemplateDeploymentScheme option := TemplateDeploymentWindow([
        "iterate":realTemplate.templateTree.roots.vals.first.layer.options["iterate"],
        "recMap":[
                   "Site":prj.database.getClassMap(Site#),
                   "Equip":prj.database.getClassMap(Equip#),
                   "Point":prj.database.getClassMap(pbpcore::Point#),
                   "Selected":[:]//TODO 1.1.1
                 ],
        "currentProject":prj
        ],e.window).open
        options := [:]
      /*
      Int? repeat := Int.fromStr(option,10,false)

      if(repeat!=null && repeat != 0)
      {
        options = ["repeat":repeat]
      }
      */
      ActorPool newPool := ActorPool()
      ProgressWindow progressWindow := ProgressWindow(e.window, newPool)
      options.add("phandler",progressWindow.phandler)

      //TemplateEngine.deployTemplate(template, prj, options, newPool)

      TemplateEngine.deployX(realTemplate,
        [
        "deployscheme":option,
        "visitors":[TemplateInheritance()],
        "dbthread": prj.database.getThreadSafe((realTemplate.templateTree.datamash.keys.size*option.templateDeployer.size),progressWindow.phandler,newPool),
        ]
      )

    /*
    ActorPool newPool := ActorPool()
    ProgressWindow progressWindow := ProgressWindow(e.window, newPool)
    Template template := tempExp.templateTableModel->getRows(tempExp.templateTable.selected)->first->readObj
    Record[] recsToAdd := [,]
    repeat.times |->|
    {
      Str:Str newRecMap := [:]
      template.templateTree.walk |treenode, parentnode, layer|
      {
        //CASE OF A ROOT
        if(parentnode == null)
        {
          Record replication := RecordFactory.replicateFromTemplateRecord(treenode.record)
          newRecMap.add(treenode.record.id.toStr, replication.id.toStr)
          recsToAdd.push(replication)
        }
        else if(!newRecMap.containsKey(treenode.record.id.toStr) && newRecMap.containsKey(parentnode.record.id.toStr)) //CASE OF NORMAL NODE, UNPROCESSED
        {
         /*
          if(!newRecMap.containsKey(treenode.record.id.toStr)) //MAKE SURE WE DIDNT ALREADY PROCESS IT
          {
            Record replication := RecordFactory.replicateFromTemplateRecord(treenode.record)
            if(!newRecMap.containsKey(treenode.record.id.toStr))//IF THE PARENT HASNT BEEN PROCESSED, GO AHEAD AND DO IT HERE
            {
              Record replicationtwo := RecordFactory.replicateFromTemplateRecord(parentnode.record)
              newRecMap.add(parentnode.record.id.toStr, replicationtwo.id.toStr)
              recsToAdd.push(replicationtwo)
            }
            replication = replication.set(TagFactory.setVal(layer.parentRef, Ref.fromStr(newRecMap[parentNode.id.toStr])))

          }
          */

        }
        else
        {

        }
      }
    }
    DatabaseThread dbthread := prj.database.getThreadSafe( recsToAdd.size,progressWindow.phandler, newPool)
    */
    progressWindow.open()
    newPool.stop()
    newPool.join()
    prj.database.unlock()

    pbpwrapper.siteExplorer.update(prj.database.getClassMap(Site#))
    pbpwrapper.equipExplorer.update(prj.database.getClassMap(Equip#))
    pbpwrapper.pointExplorer.update(prj.database.getClassMap(pbpcore::Point#))
    pbpwrapper.siteExplorer.refreshAll
    pbpwrapper.equipExplorer.refreshAll
    pbpwrapper.pointExplorer.refreshAll

    /*
    PbpWorkspace pbpWkspace := PbpWorkspace(pbp)

    Table[] tables := [pbpWkspace.siteTable, pbpWkspace.equipTable, pbpWkspace.pointTable]
    tables.each |table|
    {
      table.model->update
      table.refreshAll
    }
    */
    }
    return
  }
}

class NewTemplate : Command
{
  private PbpListener pbp
  new make(PbpListener pbp):super.makeLocale(Pod.find("projectBuilder"), "newTemplate")
  {
    this.pbp = pbp
  }

  override Void invoked(Event? e)
  {
    prj := pbp.prj
    PbpWorkspace ws := pbp.workspace
    //todo...
    File? ttypefile := TemplateKindChooser(e.window).open
    if(ttypefile != null)
    {
      TemplateType ttype := ttypefile.in.readObj
      TemplateEditor te := TemplateEditor(e.window, ["TemplateType":ttype]){

      tagExp = TagExplorer.makeWithCombo(
        FileUtil.getTagDir.listFiles.find|File f->Bool|{return f.ext=="taglib"},
        TemplateAddTagInEditor(it),
        TagUtil().getTagLibCombo,
        true)

     templateTreeStruct = Tree{
       onSelect.add|g|
       {
         TemplateEditor te := g.window
         te.exchangeRecord((g.widget as Tree).selected.first)
         te.templateTreeStruct.refreshNode(te.templateTreeStruct.selected.first)
       }
       onMouseUp.add |g|
       {
         if((g.widget as Tree).nodeAt(g.pos) == null)
         {
           (g.widget as Tree).selected = [,]
         }
       }
       onPopup.add |g|
       {
         g.popup=Menu{
           MenuItem{text="Refresh All";
               onAction.add |popupevent|
               {
                 (g.widget as Tree).refreshAll
               }
             },
         }
       }

     }
    }

    te.recordEditButtonGrid.add(Button(SaveCurrentNode(te)))
    te.recordEditButtonGrid.relayout
    te.leftBox.top = GridPane{numCols=2;
      Button(AddTemplateRecord(te)),
      Button(DeleteTemplateRecord(te)),
      Button(RemoveHisTags(te)),
    }
    Template? template := te.open
    if(template !=null)
      {
        template.save(FileUtil.templateDir)

        templateExplorer := e.widget.parent.parent as TemplateExplorer ?: throw Err("e.widget.parent.parent is not TemplateExplorer")
        templateExplorer.update()
        templateExplorer.refreshAll
      }
    }
  }
}

class SaveCurrentNode : Command
{
  private TemplateEditor te
  new make(TemplateEditor te):super.makeLocale(Pod.find("projectBuilder"), "saveCurrentNode")
  {
    this.te = te
  }

  override Void invoked(Event? e)
  {
    if(te.recordEditWrapper.content is RecordEditPane)
    {
      te.saveCurrentNode
      (te.recordEditWrapper.content as RecordEditPane).saveStatus.getAndSet(true)
      (te.recordEditWrapper.content as RecordEditPane).watcher.set
    }
  }
}

class DeleteTemplate : Command
{
  new make():super.makeLocale(Pod.find("projectBuilder"), "deleteTemplate")
  {
  }

  override Void invoked(Event? e)
  {
    TemplateExplorer exp := e.widget.parent.parent
    File[] deathrow := exp.getSelected
    resp := Dialog.openWarn(e.window, "Are you sure you want to delete ${deathrow.size} Template Files?",null,Dialog.yesNo)
    if(resp==Dialog.yes)
    {
      deathrow.each |file|
      {
        file.delete
      }
      exp.update()
      exp.refreshAll
    }
  }
}

class EditTemplate : Command
{
  private PbpListener pbp
  new make(PbpListener pbp):super.makeLocale(Pod.find("projectBuilder"), "editTemplate")
  {
    this.pbp =pbp
  }

  override Void invoked(Event? e)
  {
    prj := pbp.prj
    PbpWorkspace ws := pbp.workspace
    //TODO: Select Type... render layers somehow...
    TemplateExplorer exp := ws.templateExplorer
    File? templateFile := exp.getSelected.first
    if(templateFile != null)
    {
      Template templateed := templateFile.readObj
      TemplateEditor te := TemplateEditor(e.window, ["Template":templateed]){

      tagExp = TagExplorer.makeWithCombo(
        FileUtil.getTagDir.listFiles.find|File f->Bool|{return f.ext=="taglib"},
        TemplateAddTagInEditor(it),
        TagUtil().getTagLibCombo,
        true)

     templateTreeStruct = Tree{
       multi = true
       onSelect.add|g|
       {
         TemplateEditor te := g.window
         te.exchangeRecord((g.widget as Tree).selected.first)
         te.templateTreeStruct.refreshNode(te.currentTreeNode)
       }
       onMouseUp.add |g|
       {
         if((g.widget as Tree).nodeAt(g.pos) == null)
         {
           (g.widget as Tree).selected = [,]
         }
       }
       onPopup.add |g|
       {
         g.popup=Menu{
           MenuItem{text="Refresh All";
               onAction.add |popupevent|
               {
                 (g.widget as Tree).refreshAll
               }
             },
         }
       }
     }
    }
    te.leftBox.top = GridPane{numCols=2;Button(AddTemplateRecord(te)),Button(DeleteTemplateRecord(te)), /*Button(RemoveHisTags(te)),*/}

    te.recordEditButtonGrid.add(Button(SaveCurrentNode(te)))
    te.recordEditButtonGrid.relayout
    Template? template := te.open
    if(template !=null)
      {
        template.save(FileUtil.templateDir)
        exp.update()
        exp.refreshAll
      }
    }
  }
}

class AddTemplateRecord : Command
{
  private TemplateEditor te
  new make(TemplateEditor te): super.makeLocale(Pod.find("projectBuilder"), "addTemplateRecord")
  {
    this.te = te
  }

  override Void invoked(Event? e)
  {
    TemplateTreeModel templateTreeModel := te.templateTreeModel

    if(te.templateTreeStruct.selected.size == 0)
    {
      templateTreeModel.addRec(templateTreeModel.templateTree.tType.layers.first.getNewRec)
    }
    else
    {
      TemplateLayer parentLayer := (te.templateTreeStruct.selected.first as TemplateTreeNode).layer
      TemplateLayer[] layers := te.templateTreeModel.templateTree.tType.layers
      Int parentLoc := layers.findIndex |TemplateLayer layer->Bool| {return layer.name == parentLayer.name}
      if(layers.size-1 < parentLoc+1){return}
      TemplateLayer? childLayer := layers[parentLoc+1]
      Record newRec :=  childLayer.getNewRec((te.templateTreeStruct.selected.first as TemplateTreeNode).record)
      templateTreeModel.addRec(newRec)
    }
    if(te.templateTreeStruct.selected.size == 0)
    {
      te.templateTreeStruct.refreshAll
    }
    else if(te.templateTreeStruct.selected.size == 1)
    {
      te.templateTreeStruct.refreshNode(te.templateTreeStruct.selected.first)
//      te.templateTreeStruct.show(te.templateTreeStruct.selected.first->children->last)
      //te.templateTreeStruct.refreshAll
    }
  }
}

class DeleteTemplateRecord : Command
{
  private TemplateEditor te
  new make(TemplateEditor te): super.makeLocale(Pod.find("projectBuilder"), "delTemplateRecord")
  {
    this.te = te
  }

  override Void invoked(Event? e)
  {
    TemplateTreeModel templateTreeModel := te.templateTreeModel
    Tree templateTree := te.templateTreeStruct
    templateTree.selected.each |node|
    {
      templateTreeModel.deleteRec((node as TemplateTreeNode).record)
    }
    templateTree.refreshAll
  }
}

class RemoveHisTags : Command
{
  private TemplateEditor te
  new make(TemplateEditor te): super.makeLocale(Pod.find("projectBuilder"), "removeHisTags")
  {
    this.te = te
  }

  override Void invoked(Event? e)
  {
    lib := Env.cur.homeDir+`resources/tags/hisremove.taglib`
    tagLib := TagLib.fromXml(lib)
    TemplateTreeModel templateTreeModel := te.templateTreeModel
    Tree templateTree := te.templateTreeStruct

    toRemove := [,]
    tagLib.tags.each
    {
      toRemove.add(it.name)
    }

    templateTreeModel.templateTree.datamash.each |v, k|
    {
      Record rec := v.record
      rec = rec.removeTags(toRemove)
      templateTreeModel.updateRec(rec)
    }

    templateTree.refreshAll
  }
}


class NewTemplateType : Command
{
  private PbpListener pbp
  new make(PbpListener pbp):super.makeLocale(Pod.find("projectBuilder"), "newTemplateType")
  {
    this.pbp = pbp
  }
  override Void invoked(Event? e)
  {
    prj := pbp.prj
    PbpWorkspace ws := pbp.workspace
      Bool save := false
      Instruction[] basics :=
      [
        Instruction("Must have these tags:", WatchId.have),
        Instruction("Must have these tags with these values:", WatchId.haveVal),
        Instruction("Must not have these tags:", WatchId.haveNot),
        Instruction("You can find the parent reference from this tag:", WatchId.parentRef),
        Instruction("Please inheret these tags from the parent:", WatchId.inherit),
        Instruction("Must be this type of Record:", WatchId.isType).addField(Combo{items=["ignore","Site","Equip","Point"]}),
        Instruction("Iteration Option", WatchId.iterationOpts).addField(Combo{items=["repeat","assign","model"]})
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

     wiz.nameText = Text{text="New Template Type"}
     wiz.leftWrapper.top = EdgePane{
       bottom=ToolBar{Button(AddTemplateLayer(wiz)),}
       top=GridPane{numCols=2; Label{text="Name: "}, wiz.nameText,}
       }
     wiz.leftWrapper.bottom = ButtonGrid{numCols=2;
       Button{text="Save"; onAction.add|g|{save=true; g.window.close}},
       Button{text="Close"; onAction.add|g|{g.window.close}},
      }
     wiz.onClose.add |g|
     {
       if(save)
       {
       Wizard wiza := g.widget
       TemplateType templatetype := TemplateUtil.interpretType(wiza)
       templatetype.save(FileUtil.templateDir)
       TemplateExplorer exp := e.widget.parent.parent
       exp.update
       exp.refreshAll
       }
     }
     wiz.open
  }
}

class EditTemplateType : Command
{
  private PbpListener pbp
  new make(PbpListener pbp):super.makeLocale(Pod.find("projectBuilder"), "editTemplateType")
  {
    this.pbp = pbp
  }
  override Void invoked(Event? e)
  {
    prj := pbp.prj
    PbpWorkspace ws := pbp.workspace
      Bool save := false

      File? templateTypeFile := ws.templateTypeExplorer.getSelected.first
      if(templateTypeFile==null){return}

      TemplateType templateType := templateTypeFile.readObj()
      InstructionBox[] instBoxes := [,]
      templateType.layers.each |layer|
      {
       instBoxes.push(TemplateUtil.makeInstructionBoxFromLayer(layer))
      }
      Wizard wiz := Wizard(e.window){
        boxes = instBoxes

        it.tagExp = TagExplorer.makeWithCombo(
            FileUtil.getTagDir+`standard.taglib`,
            TemplateAddTag(it),
            TagUtil().getTagLibCombo,
            true)

      }

     wiz.nameText = Text{text=templateType.name}
     wiz.leftWrapper.top = EdgePane{
       bottom=ToolBar{Button(AddTemplateLayer(wiz)),}
       top=GridPane{numCols=2; Label{text="Name: "}, wiz.nameText,}
       }
     wiz.leftWrapper.bottom = ButtonGrid{numCols=2;
       Button{text="Save"; onAction.add|g|{save=true; g.window.close}},
       Button{text="Close"; onAction.add|g|{g.window.close}},
      }
     wiz.onClose.add |g|
     {
       if(save)
       {
       Wizard wiza := g.widget
       TemplateType templatetype := TemplateUtil.interpretType(wiza)
       templatetype.save(FileUtil.templateDir)
       TemplateExplorer exp := ws.templateTypeExplorer
       exp.update
       exp.refreshAll
       }
     }
     wiz.open
  }
}

class DeleteTemplateTypeFile : Command
{
  new make(): super.makeLocale(Pod.find("projectBuilder"), "deleteTempTypeFile")
  {
  }

  override Void invoked(Event? e)
  {
    TemplateExplorer exp := e.widget.parent.parent
    File[] deathrow := exp.getSelected
    resp := Dialog.openWarn(e.window, "Are you sure you want to delete ${deathrow.size} Template Type Files?",null,Dialog.yesNo)
    if(resp==Dialog.yes)
    {
      deathrow.each |file|
      {
        file.delete
      }
      exp.update()
      exp.refreshAll
    }
  }
}

class TemplateAddTag : Command
{
  private Wizard wizard
  new make(Wizard wizard) : super.makeLocale(Pod.of(this), "editTagsInLib")
  {
    this.wizard = wizard
  }

  override Void invoked(Event? e)
  {
    wizard.boxes.each |box|
    {
      box.instructions.each |instruct|
      {
        if((instruct.desc as SelectableLabel).selected == true && instruct.id != WatchId.isType)
        {
          Tag[] tags := wizard.tagExp.getSelected
          tags.each |tag|
          {
            instruct.addField(InstructionSmartBox(tag))
          }
          instruct.relayout
        }
      }
      box.relayout
      box.parent.relayout
      box.parent.parent.relayout
      box.parent.parent.parent.relayout
      box.parent.parent.parent.parent.relayout
    }
    wizard.relayout
  }
}

class TemplateAddTagInEditor : Command
{
  private TemplateEditor editor
  new make(TemplateEditor editor) : super.makeLocale(Pod.find("projectBuilder"), "addTagInEditor")
  {
    this.editor = editor
  }

  override Void invoked(Event? e)
  {
    Tag[] tagstoadd := editor.tagExp.getSelected
    (editor.recordEditWrapper.children.first as RecordEditPane).addAllTags(tagstoadd)
    editor.recordEditWrapper.relayout
    editor.recordEditWrapper.parent.relayout
  }
}

class AddTemplateLayer : Command
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
        Instruction("Please inheret these tags from the parent:", WatchId.inherit),
        Instruction("Must be this type of Record:", WatchId.isType).addField(Combo{items=["ignore","Site","Equip","Point"]})
      ]
    InstructionBox newlayer := InstructionBox("New Layer", basics)
    wizard.addBox(newlayer)
  }


}


class Templatize : Command
{
  private PbpListener pbp
  new make(PbpListener pbp) : super.makeLocale(Pod.find("projectBuilder"), "templatize")
  {
    this.pbp =pbp
  }

  override Void invoked(Event? e)
  {
    prj := pbp.prj
    PbpWorkspace ws := pbp.workspace
    if(prj == null) {return}
    File? templateTypeFile := ws.templateTypeExplorer.getSelected.first
    if(templateTypeFile==null){return}
    TemplateType templateType := templateTypeFile.readObj()
    TemplateTree tree := TemplateUtil.templatize(prj.database, templateType)
    TemplateUtil.fakeTemplate(ws, tree)
  }
}





