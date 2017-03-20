/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using util
using pbpgui

class Console
{

  Tree output
  Text input
  Bool loaded := false
  TextCommand? currentCommand := null
  Session[] sessions := [,]
  const Str sessionHandle := Uuid().toStr
  ConsoleManager cm
  new make(ConsoleManager cm)
  {
     this.cm = cm
     //Load past sessions
     filteredsessions := [,]
     cm.sessionDirectory.listFiles.findAll |File f->Bool|{return f.ext =="session"}.each |session|
     {
       filteredsessions.push(Session.fromJson(
         JsonInStream(session.in).readJson->get("session")
           )
           )
     }

     sessions.push(Session{text="Past $cm.name Sessions"; children = filteredsessions})
     sessions.push(Session{text="$cm.name - $DateTime.now()"; children=[,]})


     //Build Widgets
     output = Tree{
        model = ConsoleTreeModel(sessions)
        onAction.add |e|
          {
            if(!loaded)
            {
            currentCommand = TextCommand{
              text = e.data->text.toStr
              ts = Time.now.toStr
              opts = e.data->opts
            }
            addTextCommand(currentCommand)
            }
            else
            {
              addTextCommand(currentCommand)
              loaded = false
            }
          }
      }

     input = Text{
       font = Font{ size = 14 }
       onAction.add |e|
       {

       if(!loaded)
            {
            currentCommand = TextCommand{
              text = (e.widget as Text).text.toStr
              ts = Time.now.toStr
              opts = cm.opt.getDis
            }
              addTextCommand(currentCommand)
            }
            else
            {
              addTextCommand(currentCommand)
              loaded = false
            }
            (e.widget as Text).text = ""
       }

       onKeyDown.add |e|
       {
        switch(e.key)
        {
          case Key.up:
            previouscmd := sessions.last.getPrevious
            if( previouscmd != null)
            {
              (e.widget as Text).text = previouscmd.text
              currentCommand = previouscmd
              //loaded = true
            }
            return
          case Key.down:
            nextcmd := sessions.last.getNext
            if( nextcmd != null)
            {
              (e.widget as Text).text = nextcmd.text
              currentCommand = nextcmd
              //loaded = true
            }
            return
          default:
          return
        }
       }
     }
  }

  Void openView()
  {
    w := PbpWindow(null){
      size = Size(643,572)
      content = getWrapper()
    }
    w.open
  }

  Widget getWrapper(Int[] setWeight := [491,40])
  {
    wrapper := SashPane{
    weights = setWeight
    orientation = Orientation.vertical
    getOutput,
    getInput,
    }
    return wrapper
  }

  Tree getOutput()
  {
    return output
  }

  Text getInput()
  {
    return input
  }


  Void addTextCommand(TextCommand content)
  {
    currentCommand = content
    sessions.last.addTextCommand(content.text+":::"+content.ts+":::"+content.opts)
    //handle UI
    output.refreshNode((output.model as ConsoleTreeModel).lastNode)
    output.setExpanded((output.model as ConsoleTreeModel).lastNode,true)
    output.show((output.model as ConsoleTreeModel).lastNode->children->last)

    //process Command
    cm.process([content.text+":::"+content.ts+":::"+content.opts])

    //save session data
    map := ["session":sessions.last]
    targetfileout := cm.sessionDirectory.createFile("Session@${sessionHandle}"+".session").out
    JsonOutStream(targetfileout).writeJson(map).close
    targetfileout.close
  }

}
