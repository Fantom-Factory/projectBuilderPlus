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

class ObixLoginPrompt
{
    Str dis := ""
    Str host := ""
    Str user := ""
    Str pass := ""

    new make(Str dis, Str host, Str user, Str pass)
    {
      this.dis = dis
      this.host = host
      this.user = user
      this.pass = pass
    }

    static Map open(Window parentWindow, Str:Str vals := [:])
    {
        cancelFlag := false
        dis  := ""
        host := ""
        user := ""
        pass := ""
        Text disText := Text{text= vals["dis"] ?: "<enter display name here>"}
        Text hostText := Text{text= vals["host"] ?: "http://myobixserver/obix"}
        Text userText := Text{text= vals["user"] ?: "obix"}
        Text passText := Text{text= vals["pass"] ?: ""; password=true}
        Button connect := Button{text = "Add"
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
        title = "New Obix Connection"
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
           dis = disText.text
           host = hostText.text
           user = userText.text
           pass = passText.text
           }
        }
        dialog.open

      return ["cancelled" : cancelFlag.toStr,
              "dis" : dis,
              "host" : host,
              "user" : user,
              "pass" : pass]
    }


}

