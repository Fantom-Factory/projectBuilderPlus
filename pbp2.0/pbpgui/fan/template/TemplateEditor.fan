/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

using pbpcore

class TemplateEditor : PbpWindow
{
  Text templateNameText := Text{text="New Template"}
  Text templateCategoryText := Text{text="Common"}
  Text templateClassText := Text{text=""}
  LayerPane layerLayeroutter := LayerPane{} //Question: Make this a class ?
  TemplateTreeNode? currentTreeNode := null
  SashPane mainWrapper := SashPane{}
  EdgePane bigWrapper := EdgePane{}
  EdgePane leftBox := EdgePane{}
  ScrollPane recordEditWrapper := ScrollPane{}
  ButtonGrid recordEditButtonGrid := ButtonGrid{numCols=1;}
  Bool cancel := false

  TagExplorer tagExp
  TemplateTreeModel? templateTreeModel
  Tree? templateTreeStruct


  new make(Window? parent, Map? options := null, |This|? f := null) : super(parent)
  {
    if(options.containsKey("TemplateType"))
    {
      templateTreeModel = TemplateTreeModel(TemplateTree{tType=options["TemplateType"]})
    }
    if(options.containsKey("Template"))
    {
        template := options["Template"] as Template

      templateTreeModel = TemplateTreeModel(template.templateTree)
      templateNameText = Text{text=template.name}
      templateCategoryText = Text{text=template.category}
      templateClassText = Text{text=template.templateClass}
    }
    f(this)
  }

  Void exchangeRecord(TemplateTreeNode rec)
  {
      if(recordEditWrapper.children.size > 0)
      {
        if(currentTreeNode != null)
        {
         // currentTreeNode.record = TemplateRecord.fromRecord(recordEditWrapper.children.first->getRec)
         // templateTreeStruct.refreshNode(currentTreeNode)
          (recordEditWrapper.content as RecordEditPane).exchangeRec(RecordFactory.recordFromTemplateRec(rec.record))
          currentTreeNode = rec
          recordEditWrapper.relayout
          recordEditWrapper.parent.relayout
         // templateTreeStruct.refreshNode(currentTreeNode)
        }
      }
      else
      {
        currentTreeNode = rec
        RecordEditPane newEditPane := RecordEditPane(RecordFactory.recordFromTemplateRec(rec.record))
        recordEditWrapper.content = newEditPane
        (recordEditWrapper.parent.parent as EdgePane).top=newEditPane.getSaveStatusLabel
        recordEditWrapper.relayout
        recordEditWrapper.parent.relayout
        recordEditWrapper.parent.parent.relayout
      }
  }

  Void saveCurrentNode()
  {
    if(recordEditWrapper.children.size > 0)
    {
      if(currentTreeNode != null)
      {
        currentTreeNode.record = TemplateRecord.fromRecord((recordEditWrapper.children.first as RecordEditPane).getRec)
        templateTreeModel.templateTree.datamash[currentTreeNode.record.id.toStr].record = currentTreeNode.record
      }
    }
  }

  override Obj? open()
  {
    size = Size(1262,718)
    templateTreeStruct.model = templateTreeModel
    leftBox.center = templateTreeStruct
    mainWrapper.add(leftBox)
    mainWrapper.add(EdgePane{top=Label{text="No Record Selected"}; center=InsetPane(0,0,0,0){recordEditWrapper,}; bottom=recordEditButtonGrid;})
    mainWrapper.add(tagExp)
    mainWrapper.weights = [597,365,300]
    bigWrapper.center = mainWrapper
    bigWrapper.top = GridPane{
      numCols=4;
      Label{text="Name"},
      templateNameText,
      Label{text="Template Type "},
      Text{text=templateTreeModel.templateTree.tType.name; editable=false},
      Label{text="Category"},
      templateCategoryText,
      Label{text="Class"},
      templateClassText,
      }
    bigWrapper.bottom = GridPane{
      numCols=2;
      halignPane = Halign.right
      Button(Dialog.ok), Button(Dialog.cancel){onAction.add|e|{cancel=true}},
      }
    content=bigWrapper
    super.open()
    TemplateTree tree := templateTreeModel.templateTree
    Template template := Template
    {
      it.name = templateNameText.text
      it.category = templateCategoryText.text
      it.templateClass = templateClassText.text
      it.templateTree = tree
    }
    if(cancel)
    {
    return null
    }
    else
    {
    return template
    }
  }
}


