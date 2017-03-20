/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpi
using pbpgui
using pbplogging
using projectBuilder

class SkysparkLoginPrompt : PbpWindow
{
  Label disLabel := Label{text="Display Name"}
  Label userLabel := Label{text="Username"}
  Label hostLabel := Label{text="Host Server"}
  Label projectLabel := Label{text="Project"}
  Label passLabel := Label{text="Password"}

  Text disText := IText{}
  Text userText := IText{}
  Text hostText := Text{}
  Text projectText := IText{}
  Text passText := IText{password=true}

  Combo prefixCombo := Combo{items=["http://"]}
  Combo sasCombo := Combo{}

  GridPane buttonWrapper

  Bool connect := false

  SkysparkConn? conn

  private ProjectBuilder pbp

  new make(ProjectBuilder pbp, SkysparkConn? conn := null, Window? parent := null) : super(parent)
  {
    this.conn = conn
    this.pbp = pbp

    sasCombo.items = pbp.licenseInfo.sasHosts.keys
    if(pbp.licenseInfo.unlimitedSas)
      sasCombo.items = [,]

    if(conn != null)
    {
      port := conn.host.toUri.port
      disText = IText{text=conn.dis}
      userText = IText{text=conn.user}
      hostText = Text{text=conn.host.toUri.host + (port != null ? ":$port" : "")}
      projectText = IText{text=conn.host.split('/')[4]}
      buttonWrapper = GridPane{
        numCols = 2;
        halignPane = Halign.right
        Button{text="Save"; onAction.add|e|{connect = true; e.window.close}},
        Button{text="Cancel"; onAction.add|e|{e.window.close}},
      }
    }
    else
    {
      buttonWrapper = GridPane{
        numCols = 2;
        halignPane = Halign.right
        Button{text="Connect"; onAction.add|e|{connect = true; e.window.close}},
        Button{text="Cancel"; onAction.add|e|{e.window.close}},
      }
    }
  }

  Void getConn()
  {
    server := sasCombo.items.isEmpty ? hostText.text : sasCombo.selected.toStr
    Str host := prefixCombo.selected.toStr+server+"/api/"+projectText.text
    try
    {
    conn = SkysparkConn(disText.text, host, userText.text, passText.text, pbp.licenseInfo)
    }
    catch(Err err)
    {
        Logger.log.err("Connection retrieval error", err)
        Dialog.openErr(null,"$err",err)
    }
  }

  override Obj? open()
  {
    EdgePane mainWrapper := EdgePane()
    GridPane hostWrapper := GridPane
    {
      numCols=2;
      prefixCombo,
      (sasCombo.items.isEmpty ? hostText : sasCombo),
    }
    GridPane connWrapper := GridPane{
      numCols = 2;
      expandCol = 1;
      disLabel, disText,
      hostLabel, hostWrapper,
      projectLabel, projectText,
      userLabel, userText,
      passLabel, passText,
    }

    mainWrapper.center = InsetPane(1,1,1,1){connWrapper,}
    mainWrapper.bottom = buttonWrapper
    title = "Add new Skyspark Project"
    icon = Desktop.isMac?PBPIcons.pbpIcon64:PBPIcons.pbpIcon64
    content = mainWrapper
    onClose.add |e|
    {
      if(connect)
      {
        getConn
      }
    }
    super.open()
    return conn
  }
}
