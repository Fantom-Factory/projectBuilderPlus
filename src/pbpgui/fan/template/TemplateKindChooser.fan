/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpi

class TemplateKindChooser : PbpWindow
{
  EdgePane mainWrapper := EdgePane{}
  Bool cont := false

  private Table templateTypeTable
  private TemplateTypeTableModel templateTypeTableModel

  new make(Window? parent):super(parent)
  {
    this.templateTypeTableModel = TemplateTypeTableModel()
    this.templateTypeTable = Table() { it.model = templateTypeTableModel }

  }

    File[] getSelected()
    {
        return templateTypeTableModel.getRows(templateTypeTable.selected)
    }

  override Obj? open()
  {


    icon = PBPIcons.pbpIcon16
    size = Size(301,281)
    mainWrapper.top=Label{text="Which Template Type Would you like to use?"}
    mainWrapper.center=templateTypeTable
    mainWrapper.bottom=ButtonGrid{numCols=2;
       Button{text="Continue"; onAction.add|e|{cont=true; e.window.close;}},
       Button{text="Cancel"; onAction.add|e|{e.window.close;}},
     }
    content = mainWrapper
    super.open()

    selected := getSelected

    if(cont && selected.size > 0)
    {
      return selected.first
    }
    else
    {
      return null
    }
  }
}
