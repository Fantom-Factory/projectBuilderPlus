/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using gfx
using fwt
using concurrent
using pbpi

** A progress bar window
** Use phandler to send progress messages and Done message
class ProgressWindow : PbpWindow
{
   ProgressBar pbar
   Label displayText
   Label pmsg
   ProgressHandler phandler
   ActorPool pool
   EdgePane mainWrapper := EdgePane{}
   EdgePane bigWrapper := EdgePane{}
   //Button runInBackButton := Button{text="Run In Background"; onAction.add|e|{e.window.close}}
   Button cancelButton := Button{text="Cancel"; onAction.add|e|{phandler.pool.stop; e.window.close}}
   GridPane buttonWrapper := GridPane{numCols=1; halignPane=Halign.right; /*runInBackButton,*/ cancelButton,}

   new make(Window? parent, ActorPool pool, Str msgText := "") : super(parent)
   {
     this.pool = pool
     pbar = ProgressBar{max=100}
     pmsg = Label{text=""}
     phandler = ProgressHandler(pbar,pmsg,pool)
     displayText = Label{text=msgText}
   }


   override Obj? open()
   {
     icon = PBPIcons.pbpIcon16
     size = Size(435,128)
     mainWrapper.top = displayText
     mainWrapper.center = pbar
     mainWrapper.bottom = pmsg
     bigWrapper.center = mainWrapper
     bigWrapper.bottom = buttonWrapper
     content = bigWrapper
     relayout()
     super.open()
     if(phandler.done.val !=true)
     {
       return phandler
     }
     return null
   }
}
