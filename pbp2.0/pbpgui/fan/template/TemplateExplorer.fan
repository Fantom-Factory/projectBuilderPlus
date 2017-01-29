/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore
using fwt
using gfx
using pbplogging

class TemplateExplorer : EdgePane
{
  private ToolBar templateToolbar
  private Table templateTable
  private AbstractTemplateTableModel templateTableModel

  new make(AbstractTemplateTableModel templateTableModel, ToolBar templateToolbar, Command commandAddButton) : super()
  {
    this.templateToolbar = templateToolbar
    this.templateTableModel = templateTableModel

    this.templateTable = Table() { multi = true }
    this.templateTable.model = this.templateTableModel
    this.templateTable.onPopup.add |Event e|
    {
        e.popup=Menu() { MenuItem(MultiEditTemplateProperties(this)), }
    }

    this.top = templateToolbar
    this.center = templateTable
    this.left = Button(commandAddButton)
  }

    Void update()
    {
        templateTableModel.update()
    }

    Void refreshAll()
    {
        templateTable.refreshAll
    }

    File[] getSelected()
    {
        return templateTableModel.getRows(templateTable.selected)
    }

    Void addOnTableAction(|Event| f)
    {
        templateTable.onAction.add(f)
    }

}


 class MultiEditTemplateProperties : Command
 {
   TemplateExplorer templateExp
   new make(TemplateExplorer templateExp) : super.makeLocale(Pod.of(this), "multiEditTemplateProperties")
   {
     this.templateExp = templateExp
   }

   override Void invoked(Event? event)
   {
     if(templateExp.getSelected.size > 0)
     {
       File[] selectedFiles := templateExp.getSelected
       newprops := MultiEditTemplatePropertiesWindow(event.window).open as Str:Str
       if(newprops!=null){
         selectedFiles.each |file|
         {
           Template oldTemplate := file.readObj
           Template newTemplate := Template{
             it.name= oldTemplate.name
             it.category= newprops["category"]
             it.templateClass= newprops["class"]
             it.templateTree= oldTemplate.templateTree
           }
           file.writeObj(newTemplate)
         }
         templateExp.update()
         templateExp.refreshAll
       }
     }
   }
 }

 class MultiEditTemplatePropertiesWindow : PbpWindow
 {
   Bool save := false
   Text categoryText := Text{}
   Text classText := Text{}
   new make(Window? parentWindow): super(parentWindow){}

   override Obj? open()
   {
     content = EdgePane{
       center = GridPane{
         numCols = 2;
           Label{text="Category "},
             categoryText,
               Label{text="Class "},
                 classText,
       }
       bottom = ButtonGrid{
         numCols=2;
           Button{text="Ok"; onAction.add|e|{save=true; e.window.close}},
             Button(Dialog.cancel),
           }
     }
     super.open()
     if(save)
     {
       return ["category":categoryText.text, "class":classText.text]
     }
     return null
   }

 }
