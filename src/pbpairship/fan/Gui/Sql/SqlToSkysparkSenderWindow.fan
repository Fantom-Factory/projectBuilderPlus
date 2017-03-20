/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore
using pbpsql
using pbpgui
using pbplogging
//Pick sender type..
//Pick project..
//Pick scheme..
//Pick targeting method..

class SqlToSkysparkSenderWindow : PbpWindow
{
  //Current sender options:
  //hisWrite
  SqlToSkyhisWriteForm hisForm
  EdgePane mainWrapper := EdgePane{}
  TabPane tabPane := TabPane{}
  Text senderText := Text{}
  Project targetProject

  Bool save := false

  new make(Window parentWindow, Project targetProject) : super(parentWindow)
  {
    this.targetProject = targetProject
    hisForm = SqlToSkyhisWriteForm(targetProject.homeDir)
  }

  override Obj? open()
  {
    size=Size(544,458)
    tabPane.add(Tab{text="Import History"; hisForm,})
    mainWrapper.top = GridPane{numCols=2; Label{text="Sender Name"}, senderText, }
    mainWrapper.center = tabPane
    mainWrapper.bottom = ButtonGrid{numCols=2;
      Button{text="Save"; onAction.add|e|{save=true; e.window.close}},
        Button{text="Cancel"; onAction.add|e|{e.window.close}},
          }
    content=mainWrapper
    super.open()
    if(save)
    {
      return SqlToSkysparkSender{
      sqlConnFile = hisForm.sqlFiles.uri
      options = [
                  "name": senderText.text,
                  "addresses": hisForm.skysparkFiles.uri,
                  "hisWriteFullSql":hisForm.fullCheck.selected,
                  "hisWriteHybrid":hisForm.hybridCheck.selected,
                  "hisWrite":hisForm.schemeFiles.map|File f-> SqlPackageDeploymentScheme|{return f.readObj}
                  ]
      manifestDirectory = [:].addList((targetProject.connDir+`sql/`).listFiles.findAll |File f->Bool|{return f.ext=="db"}.map|File f-> Uri|{return f.uri}) |Uri uri -> Str| {return uri.toStr}
    }
    }
    else
    {
      return null
    }
  }
}

**
**  Form to set up his write
**
class SqlToSkyhisWriteForm : EdgePane
{

  File? skysparkFiles := null
  File? sqlFiles := null
  File[] schemeFiles := [,]

  Str[] targetPoints := [,]

  Button fullCheck := Button{mode=ButtonMode.check}
  Button hybridCheck := Button{mode=ButtonMode.check}

  new make(File projectDir)
  {
    center = GridPane{
    numCols=1
    GridPane{
      numCols=2;
      Label{text="Pick Skyspark Connections"},
      Button{ text="Choose Connections..";
        onAction.add |e|
        {
          skysparkFiles = FileDialog{
            dir=projectDir+`conns/`;
              filterExts=["*.skyconn"];
                mode=FileDialogMode.openFile}.open(e.window)
        }
      },
      Label{text="Pick Sql Connections"},
      Button{ text="Choose Connections..";
        onAction.add |e|
        {
          sqlFiles = FileDialog{
            dir=projectDir+`conns/`;
              filterExts=["*.sqlconn"];
                mode=FileDialogMode.openFile}.open(e.window)
        }
      },
      Label{text="Pick Sql Scheme"},
      Button{ text="Choose Connections..";
        onAction.add |e|
        {
          schemeFiles = FileDialog{
            dir=projectDir+`conns/sql/`;
              filterExts=["*.sqlscheme"];
                mode=FileDialogMode.openFiles}.open(e.window)
        }
      },
      },
      GridPane{
        numCols=3;
        fullCheck, Label{text="Use pbpid looking at sql records"}, Label{},
        hybridCheck, Label{text="Choose existing points"}, Label{text="Option Coming Soon"},
      },
      }
      /*Button{text="Select Records"
        onAction.add |e|
        {
          targetPoints
        }
        },
        */

  }
}
