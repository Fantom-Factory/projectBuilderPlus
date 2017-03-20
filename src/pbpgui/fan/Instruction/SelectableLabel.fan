/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

class SelectableLabel : Label
{
  Bool mousein := false
  Bool selected := false
  |Event? e|? onceSelected

  new make(Str text)
  {
      font = Font{it.size=14}
      this.text=text
      onMouseEnter.add |e|
      {
        mousein=true
        if(!selected)
        {
          this.fg = Color.blue
        }
        else
        {
          this.fg = Color.green
        }
      }

      onMouseExit.add |e|
      {
        mousein=false
        if(!selected)
        {
          this.fg = Desktop.sysFg
        }
        else
        {
          this.fg = Color.green
        }
      }

      onMouseUp.add|e|
      {
        if(mousein)
        {

          e.widget.parent.children.each |child|
          {
            selectableLabel := child as SelectableLabel
            if(selectableLabel != null)
            {
              selectableLabel.selected = selectableLabel.selected.not
              selectableLabel.fg = Desktop.sysFg
              selectableLabel.repaint
            }
          }

          selected = selected.not.not
          if(selected)
          {
           // onceSelected.call(e)
           this.fg = Color.green
          }

        }
      }
   }
 }



