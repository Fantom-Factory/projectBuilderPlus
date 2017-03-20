/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using sql
using spui
using pbpi
using pbpgui
using concurrent
using pbplogging
using projectBuilder

class SqlDBEditor
{
private SqlConnWrapper conn
private Bool hasQuery := false;
Table? resultTable
new make(SqlConnWrapper target)
{
  conn = target
}

static Void open(Window parent, SqlConnWrapper target, ProjectBuilder pbp){
    SqlDBEditor editor := SqlDBEditor(target);
    if(target.server.user == "root" && target.walked == false)
    {
      resp := Dialog.openQuestion(parent, "Would you like to walk the entire server? (This operation may take a while)",null, Dialog.yesNo)
      if(resp == Dialog.yes)
      {
       target.initScript(true)
      }
      else
      {
        target.initScript(false)
      }
    }

    target.initScript(false)

    Window guiTop := PbpWindow(null)
    //GUI Buttons
    Button pingButton  := Button()
    Button queryButton := Button()
    Button sqlToolButton := Button(NewSqlPackageCommand(editor.conn))
    Button sqlDeployButton := Button(DeploySqlPackageCommand(editor.conn, pbp))
    Button sqlHistoryButton := Button(SqlHistoryImportCommand(editor.conn))
    Button sqlSchemeButton := Button(CreateDeploymentSchemeCommand(editor.conn))
    Button closeButton := Button()
    Button prevButton := Button{image = Image(`fan://icons/x16/undo.png`)}
    Button nextButton := Button{image = Image(`fan://icons/x16/redo.png`)}
    Button goButton := Button{image = Image(`fan://icons/x16/check.png`)}
    //Layout Widgets
    SashPane contentWrapper := SashPane()
    SashPane rightBox := SashPane()
    SashPane leftBox  := SashPane()
    GridPane buttonWrapper := GridPane()
    EdgePane bodyWrapper   := EdgePane()

    Label statusLabel := editor.conn.getStatusLabel

   //Attach Actions
    pingButton= mButton{
       text="About"
       onAction.add |e|{
         editor.pingAction(e) //Action to be performed
       }
      }
    queryButton = mButton{
       text="Query"
       onAction.add |e|{
         //Extended Query View
       }
       }
       /*
    sqlToolButton = mButton{
       text="SQL Tools"
       onAction.add |e|{
         editor.openToolAction(e)
       }
       }
       */
    closeButton = mButton{
       text="Close"
       onAction.add |e|{
         e.window.close
       }
       }


   //Gui Formatting/

   buttonWrapper = GridPane{
     numCols = 1;
     pingButton,
     sqlToolButton,
     sqlSchemeButton,
     sqlDeployButton,
     closeButton,
   }

   rightBox = SashPane{
     weights = [418,120]
     orientation = Orientation.vertical
     editor.conn.getServerTree,
     buttonWrapper,
   }
   Label pageLabel := Label{text="Page: 1/5"}
   editor.resultTable = editor.conn.getResultTable
   leftBox = SashPane{
      weights = [559,28,130]
      orientation = Orientation.vertical
      editor.resultTable,
      editor.conn.getPaginator,
      editor.conn.getConsoleWrapper,
   }
   contentWrapper = SashPane{
    weights = [1115,264]
    leftBox,
    rightBox,
    }
   bodyWrapper = EdgePane{
     center = contentWrapper
     bottom = statusLabel
     }

   guiTop = Window(parent){
       title = "SQL Workbench - ${target.getDis}"
       size = Size(1398,777)
       content = bodyWrapper
       icon = PBPIcons.pbpIcon16
    }
   //Env.cur.gc()
   guiTop.open
}

Void pingAction(Event e)
{
   conn.ping()
   try
   {
   SqlMeta? sqlMeta := SqlUtil.getConn(conn.server).meta
   infoGrid := GridPane{ numCols=2;
   Label{text="Last Query:"},Label{text=conn.console.currentCommand.text},
   Label{text="Last Query Time:"},Label{text=conn.console.currentCommand.ts},
   Label{text="Last Queried Database:"},Label{text=conn.console.currentCommand.opts},
   Label{text="Driver Name:"},Label{text=sqlMeta.driverName()},
   Label{text="Driver Version:"},Label{text=sqlMeta.driverVersionStr()},
   Label{text="Product Name:"},Label{text=sqlMeta.productName()},
   Label{text="Product Version:"},Label{text=sqlMeta.productVersionStr()},
   }
   Dialog.openMsgBox(Pod.of(this), "sqlAboutWindow", e.window,infoGrid)
   }
   catch(Err err)
   {
     return
   }
}

Void queryAction(Event e, Obj? updateobj := null)
{
  conn.query(updateobj->get(1));
  hasQuery = true; //not a true safety
}

Void openToolAction(Event e, Obj? updateobj := null)
{
  if(true)
  {
   SqlToolHandler.chooseTool(updateobj)
  }


}

static Table makeSqlTableView(SqlRow[] sqlrows)
{
  Table toReturn := Table{
  model = SqlTableModel()
  }
  return toReturn
}

}

internal class mButton : Button{
  new make() : super (){}
  override Size prefSize(Hints hints := Hints.defVal)
  {
    return Size(80,25)
  }
}

internal class mText : Text{
  new make(|This| f) : super(f){}
  override Size prefSize(Hints hints := Hints.defVal)
  {

    return Size(988,29)
  }
 }

@Serializable
class PaginateControllerPane : GridPane, UiUpdatable, SqlCommunicator
{
  override SqlConnWrapper sqlConn
  Label pageLabel := Label{text="Page: 1/5"}
  Button leftButton
  Button rightButton
  List pages

  Int currentPage
  Int totalPages

  new make(SqlConnWrapper sqlConn, List pages := [,])
  {
    this.sqlConn = sqlConn
    this.pages = pages
    halignPane=Halign.right;
    numCols=3;
    currentPage = 1
    totalPages = pages.size
    if(totalPages == 0){totalPages=1}
    leftButton = Button{image=PBPIcons.circleLeft16;}
    rightButton = Button{image=PBPIcons.circleRight16}
    leftButton.onAction.add |e|{
      if(currentPage!=1)
      {
        currentPage--
        pageLabel.text="Page: ${currentPage}/${totalPages}"
        communicate(this.pages[currentPage-1])
        pageLabel.parent.relayout
        pageLabel.relayout
      }
    }
    rightButton.onAction.add|e|{
      if(currentPage<totalPages)
      {
        currentPage++
        pageLabel.text="Page: ${currentPage}/${totalPages}"
        communicate(this.pages[currentPage-1])
        pageLabel.parent.relayout
        pageLabel.relayout
      }
    }
    add(leftButton)
    pageLabel.text="Page: ${currentPage}/${totalPages}"
    add(pageLabel)
    add(rightButton)
   }

   override Void updateUi(Obj? params := null)
   {
     Logger.log.debug("updating Ui")
     this.pages = params
     currentPage = 1
     totalPages = pages.size
     if(totalPages == 0){
       totalPages=1
       }
     pageLabel.text="Page: ${currentPage}/${totalPages}"
     pageLabel.parent.relayout
     pageLabel.relayout
   }

   override Void communicate(Str statement)
   {
     sqlConn.queryUnseen(statement)
   }
}

const class PaginatorHandler : Actor
{
  const Str paginatorHandler := Uuid().toStr

  new make(PaginateControllerPane paginator, ActorPool pool) : super(pool)
  {
    Actor.locals[paginatorHandler] = paginator
    Logger.log.debug(Actor.locals[paginatorHandler].toStr)
  }

  override Obj? receive(Obj? msg)
  {
      Logger.log.debug("updater")
      Desktop.callAsync |->| {
      paginator := Actor.locals[paginatorHandler] as PaginateControllerPane
      if(paginator!=null)
      {
        paginator.updateUi(msg)
      }
    }
    return null
  }
}
