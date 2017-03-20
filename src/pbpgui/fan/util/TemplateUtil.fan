/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore
using fwt
using gfx


class TemplateUtil
{
  static TemplateType interpretType(Wizard wiz)
  {
    TemplateLayer[] layer := [,]
    wiz.boxes.each |box, index| //each one of these is a layer
    {
      Watch[] watches := [,]
      Str:Tag inheritance := [:]
      Tag? parentRef := null
      Str:Obj options := [:]
      box.instructions.each |instruct|
      {
        if(instruct.id != null)
        {
          switch(instruct.id)
          {
            case WatchId.have:
              watches.push(WatchTags{tagstowatch=PbpUtil.getTagsFromInstruct(instruct);})
            case WatchId.haveVal:
              watches.push(WatchTagVals{tagstowatch=PbpUtil.getTagsFromInstruct(instruct);})
            case WatchId.haveNot:
              watches.push(WatchTagsExclude{tagstowatch=PbpUtil.getTagsFromInstruct(instruct);})
            case WatchId.parentRef:
              parentRef=PbpUtil.getTagsFromInstruct(instruct).first
            case WatchId.inherit:
              inheritance.addList(PbpUtil.getTagsFromInstruct(instruct), |Tag t->Str| {return t.name})
            case WatchId.isType:
              watches.push(WatchType{typetowatch=PbpUtil.getTypeFromInstruct(instruct)})
            case WatchId.iterationOpts:
              options.add("iterate",TemplateUtil.getIterateFromInstruct(instruct))
          }
        }
      }
      if(index==0)
      {
      layer.push(TemplateLayer{root=true; name=box.disText.text; rules=watches; it.parentref=parentRef; it.inheritance=inheritance; it.options=options})
      }
      else
      {
      layer.push(TemplateLayer{root=false; name=box.disText.text; rules=watches; it.parentref=parentRef; it.inheritance=inheritance; it.options=options})
      }
    }
    return TemplateType{name=wiz.nameText.text; it.layers = layer}
  }

  static TemplateIterationOption? getIterateFromInstruct(Instruction instruction)
  {
    Combo options := instruction.fieldWrapper.children.first
    return TemplateIterationOption.fromStr(options.selected)
  }

  static InstructionBox makeInstructionBoxFromLayer(TemplateLayer layer)
  {
    if(layer.root)
    {
      Instruction haveInstruction := Instruction("Must have these tags:", WatchId.have)
      Instruction haveValInstruction := Instruction("Must have these tags with these values:", WatchId.haveVal)
      Instruction haveNotInstruction := Instruction("Must not have these tags:", WatchId.haveNot)
      Instruction parentRefInstruction := Instruction("You can find the parent reference from this tag:", WatchId.parentRef)
      Instruction inheritInstruction := Instruction("Please inherit these tags from the parent:", WatchId.inherit)
      Instruction isTypeInstruction := Instruction("Must be this type of Record:", WatchId.isType).addField(Combo{items=["ignore","Site","Equip","Point"]})
      Instruction iterationOptsInstruction := Instruction("Iteration Option", WatchId.iterationOpts).addField(Combo{items=["repeat","assign","model"]})
      WatchTags[] watchTags := layer.rules.findAll |Obj obj->Bool| {return obj.typeof==WatchTags#}
      WatchTagVals[] watchTagVals := layer.rules.findAll |Obj obj->Bool| {return obj.typeof==WatchTagVals#}
      WatchTagsExclude[] watchTagsExclude := layer.rules.findAll |Obj obj->Bool| {return obj.typeof==WatchTagsExclude#}
      Tag? parentRef := layer.parentref
      Str:Tag inheritance := layer.inheritance
      WatchType watchType := layer.rules.find |Obj obj->Bool| {return obj.typeof==WatchType#}
      TemplateIterationOption iterationOpt := layer.options["iterate"]
      watchTags.each|watch|
      {
        watch.tagstowatch.each |tag|
        {
          haveInstruction.addField(InstructionSmartBox(tag))
        }
      }
      watchTagVals.each |watch|
      {
        watch.tagstowatch.each |tag|
        {
          haveValInstruction.addField(InstructionSmartBox(tag))
        }
      }
      watchTagsExclude.each|watch|
      {
        watch.tagstowatch.each |tag|
        {
          haveNotInstruction.addField(InstructionSmartBox(tag))
        }
      }
      if(parentRef!=null)
      {
        parentRefInstruction.addField(InstructionSmartBox(parentRef))
      }
      inheritance.each|tag|
      {
        inheritInstruction.addField(InstructionSmartBox(tag))
      }
      (isTypeInstruction.fieldWrapper.children.first as Combo).selected = watchType.typetowatch.name
      (iterationOptsInstruction.fieldWrapper.children.first as Combo).selected = iterationOpt.name
      Instruction[] basics :=
      [
        haveInstruction,
        haveValInstruction,
        haveNotInstruction,
        parentRefInstruction,
        inheritInstruction,
        isTypeInstruction,
        iterationOptsInstruction
      ]
      InstructionBox root := InstructionBox(layer.name, basics)
      return root
    }
    else
    {
      Instruction haveInstruction := Instruction("Must have these tags:", WatchId.have)
      Instruction haveValInstruction := Instruction("Must have these tags with these values:", WatchId.haveVal)
      Instruction haveNotInstruction := Instruction("Must not have these tags:", WatchId.haveNot)
      Instruction parentRefInstruction := Instruction("You can find the parent reference from this tag:", WatchId.parentRef)
      Instruction inheritInstruction := Instruction("Please inherit these tags from the parent:", WatchId.inherit)
      Instruction isTypeInstruction := Instruction("Must be this type of Record:", WatchId.isType).addField(Combo{items=["ignore","Site","Equip","Point"]})
      Instruction iterationOptsInstruction := Instruction("Iteration Option", WatchId.iterationOpts).addField(Combo{items=["repeat","assign","model"]})

      WatchTags[] watchTags := layer.rules.findAll |Obj obj->Bool| {return obj.typeof==WatchTags#}
      WatchTagVals[] watchTagVals := layer.rules.findAll |Obj obj->Bool| {return obj.typeof==WatchTagVals#}
      WatchTagsExclude[] watchTagsExclude := layer.rules.findAll |Obj obj->Bool| {return obj.typeof==WatchTagsExclude#}
      Tag parentRef := layer.parentref
      Str:Tag inheritance := layer.inheritance
      WatchType watchType := layer.rules.find |Obj obj->Bool| {return obj.typeof==WatchType#}

      watchTags.each|watch|
      {
        watch.tagstowatch.each |tag|
        {
          haveInstruction.addField(InstructionSmartBox(tag))
        }
      }
      watchTagVals.each |watch|
      {
        watch.tagstowatch.each |tag|
        {
          haveValInstruction.addField(InstructionSmartBox(tag))
        }
      }
      watchTagsExclude.each|watch|
      {
        watch.tagstowatch.each |tag|
        {
          haveNotInstruction.addField(InstructionSmartBox(tag))
        }
      }
      parentRefInstruction.addField(InstructionSmartBox(parentRef))
      inheritance.each|tag|
      {
        inheritInstruction.addField(InstructionSmartBox(tag))
      }
      (isTypeInstruction.fieldWrapper.children.first as Combo).selected = watchType.typetowatch.name
      Instruction[] basics :=
      [
        haveInstruction,
        haveValInstruction,
        haveNotInstruction,
        parentRefInstruction,
        inheritInstruction,
        isTypeInstruction
      ]
      InstructionBox root := InstructionBox(layer.name, basics)
      return root
    }
  }

  static TemplateTree templatize(PbpDatabase database, TemplateType templateType)
  {
    TemplateTree tree := TemplateTree
      {
      tType = templateType
      }
    tree.tType.layers.each |layer|
    {
      WatchType? typeWatcher := layer.rules.find|Watch w -> Bool| {return w.typeof == WatchType#}
      if(typeWatcher != null)
      {
        Map? maptoscan := database.getClassMap(typeWatcher.typetowatch)
        if(maptoscan != null)
        {
          maptoscan.vals.each |val|
          {
            layer.apply(tree,val) //TODO: Temp replace with a smarter approach
          }
        }
      }
      else
      {
        database.getClassMap(Record#).vals.each|val|
        {
          if(!tree.datamash.containsKey((val as Record).id.toStr))
            {
              layer.apply(tree,val) //TODO: Temp replace with a smarter approach
            }
        }
      }
    }
    return tree
  }

  static Void fakeTemplate(PbpWorkspace ws, TemplateTree tree)
  {
    TemplateExplorer exp := ws.templateExplorer
    Template templateed := Template{
      templateTree = tree
      name="Templatize Tree"
    }

    TemplateEditor te := TemplateEditor(Desktop.focus.window, ["Template":templateed]){

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
    te.leftBox.top = GridPane{numCols=3;Button(AddTemplateRecord(te)),Button(DeleteTemplateRecord(te)), Button(RemoveHisTags(te)),}

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


