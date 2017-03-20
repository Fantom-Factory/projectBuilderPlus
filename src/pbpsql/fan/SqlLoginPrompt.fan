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

class SqlLoginPrompt
{
    Str dis := ""
    Str host := ""
    Str user := ""
    Str pass := ""
    new make(Str dis := "<enter what you would like to label this connection here>", Str host := "jdbc:mysql://localhost:3306/fantest", Str user := "root", Str pass := "")
    {
      this.dis = dis
      this.host = host
      this.user = user
      this.pass = pass
    }

    List open(Window parentWindow)
    {
        cancelFlag := false
        Text disText := Text{text=dis}
        Text hostText := Text{text=host}
        Text userText := Text{text=user}
        Text passText := Text{text=pass; password=true}
        Button connect := Button{text = "Connect"
            onAction.add |e|{
                e.window.close
            }
        }
        Button cancel := Button{text = "Cancel"
           onAction.add |e|{
                cancelFlag = true
                e.window.close
            }
        }
        Window dialog := PbpWindow(parentWindow){
        icon = Desktop.isMac?PBPIcons.pbpIcon64:PBPIcons.pbpIcon64
        title = "New Sql Connection"
        content = EdgePane{
            center = GridPane{
                numCols = 2;
                Label{text="Display Name"},disText,
                Label{text="Host"},hostText,
                Label{text="User"},userText,
                Label{text="Pass"},passText,
            }
            bottom = GridPane{numCols=2; halignPane = Halign.right; connect,cancel}
        }

        onClose.add {
        //TODO: check for correctness?
           dis = disText.text
           host = hostText.text
           user = userText.text
           pass = passText.text
           }
        }
        dialog.open

      return [cancelFlag,dis,host,user,pass]
    }


}

