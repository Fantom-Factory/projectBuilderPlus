/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore
using fwt
using gfx
using util

class TemplateDeploymentWindow : PbpWindow
{
  GridPane optionPane := GridPane{}
  ButtonGrid buttonWrapper := ButtonGrid{numCols=2;}
  EdgePane mainWrapper := EdgePane{}
  Bool cancel := false
  Text answerText := Text{text="1"} //TODO: Temporary
  Str:Obj options
  File? csvFile := null
  Text fileText := Text{editable=false}
  new make(Str:Obj options, Window? parent) : super(parent)
  {
    this.options=options
  }

  override Obj? open()
  {
    size = Size(405,415)
    //TODO: Temporary implementation modify after version 1.1.0 is released
    TemplateIterationOption iterationOpt := options["iterate"]
    switch(iterationOpt)
    {
    case TemplateIterationOption.repeat:
    optionPane.add(
      EdgePane{
        top=GuiUtil.makeTitle("Repeat")
        center=GridPane{
          Label{text="How many times would you like to repeat this?"},
          answerText,
          }
        }
      )
    case TemplateIterationOption.assign:
    TemplateIterationOptionPane iterOptionPane := TemplateIterationOptionPane("Assign Records", "Select the Records which will root the template.")
    iterOptionPane.mainPane.add(SwitchableRecordTable(Combo{items=["Site","Equip","Point","Selected"]}, options["recMap"], options["currentProject"]))
    optionPane.add(iterOptionPane)
    optionPane.add(  EdgePane{
        top=GuiUtil.makeTitle("Repeat")
        center=GridPane{
          Label{text="How many times would you like to repeat this?"},
          answerText,
          }
        }
        )
    case TemplateIterationOption.model:
    optionPane.add(
      EdgePane{
        top=GridPane{ GuiUtil.makeTitle("Build with CSV"), Label{text="Choose CSV File to Build With"},}
        center=GridPane{
          numCols=2;
          Button{text=".."; onAction.add|e|{
            csvFile=FileDialog{filterExts=["*.csv"]}.open(e.window)
            if(csvFile!=null)
            {
              fileText.text=csvFile.uri.toStr
            }
            }}, fileText,
          }
        }
      )
    }
    buttonWrapper.add(Button{text="Continue"; onAction.add|e|{e.window.close}})
    buttonWrapper.add(Button{text="Close"; onAction.add|e|{cancel=true; e.window.close}})//TODO There is bug here
    mainWrapper.top=GuiUtil.makeTitle("Deployment Options")
    mainWrapper.center=optionPane
    mainWrapper.bottom=buttonWrapper
    content=mainWrapper
    super.open()
    switch(iterationOpt)
    {
      case TemplateIterationOption.repeat:
        return TemplateDeploymentScheme(RepeatTemplateDeployer(Int.fromStr(answerText.text, 10, false)))
      case TemplateIterationOption.assign:
        return TemplateDeploymentScheme(AssignmentTemplateDeployer((((optionPane.children.first as TemplateIterationOptionPane).mainPane as InsetPane).content as SwitchableRecordTable).getSelectedRecs, Int.fromStr(answerText.text, 10, false)))
      case TemplateIterationOption.model:
        if(csvFile!=null)
        {
        return TemplateDeploymentScheme(ModelTemplateDeployer(CsvInStream(csvFile.in).readAllRows))
        }
        else
        {
          return null
        }
      default:
        return TemplateDeploymentScheme(RepeatTemplateDeployer(1))
    }
  }

}
