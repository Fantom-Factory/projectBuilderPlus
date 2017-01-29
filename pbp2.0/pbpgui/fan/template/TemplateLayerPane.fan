/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore
using pbplogging

class TemplateLayerPane : GridPane
{
 // Label disText
  TemplateLayer layer
  Bool mousein := false
  Bool selected := false
  new make(TemplateLayer layer)
  {
     this.layer = layer
     Instruction instruction1 := Instruction("Populate with Records").addField(
     Button{text="Add Record"
       onAction.add |e|
       {
         (e.widget.parent.parent as Instruction).addField(GridPane{SelectableLabel("New_Rec"){
           it.onMouseDown.add|w|
           {
             w.window->exchangeRecord(RecordFactory.getSite) // this is probably bug / try to remove dynamic invoke
           }
           },
         })
      box := e.widget.parent.parent.parent
      box.relayout
      box.parent.relayout
      box.parent.parent.relayout
      box.parent.parent.parent.relayout
      box.parent.parent.parent.parent.relayout
       }}
     )
     Instruction instruction2 := Instruction("Add Special Rules")
     add(BorderPane{border=Border("1,1,1,1 #fff");InstructionBox(this.layer.name, [instruction1, instruction2]),})
     onMouseEnter.add |e|
      {
        mousein=true
        if(!selected)
        {
          (e.widget.parent as BorderPane).border = Border("1,1,1,1 #fff")
          e.widget.parent.repaint
        }
      }

      onMouseExit.add |e|
      {
        mousein=false
        if(!selected)
        {
          (e.widget.parent as BorderPane).border = Border("1,1,1,1 #000")
          e.widget.parent.repaint
        }
      }

      onMouseUp.add|e|
      {
        if(mousein)
        {
          selected = selected.not
          (e.widget.parent as BorderPane).border = Border("1,1,1,1 #fff")
          e.widget.parent.repaint
        }
      }
  }
}
