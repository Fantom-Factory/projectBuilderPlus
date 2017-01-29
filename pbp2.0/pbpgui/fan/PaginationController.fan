/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using concurrent
using pbpi
using pbplogging

@Serializable
class PaginationController : GridPane, UiUpdatable, UiCommunicator
{

  Label pageLabel := Label{text="Page: 1/5"}
  Button leftButton
  Button rightButton
  List pages := [,]

  Int currentPage
  Int totalPages

  new make()
  {
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
        communicate(pages[currentPage-1])
        pageLabel.parent.relayout
        pageLabel.relayout
      }
    }
    rightButton.onAction.add|e|{
      if(currentPage<totalPages)
      {
        currentPage++
        pageLabel.text="Page: ${currentPage}/${totalPages}"
        communicate(pages[currentPage-1])
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
     this.pages = params
     currentPage = 1
     totalPages = pages.size
     if(totalPages == 0){
       totalPages=1
       }
     pageLabel.text="Page: ${currentPage}/${totalPages}"
     pageLabel.parent.relayout
     pageLabel.relayout
     communicate(pages[currentPage-1])
   }

   override Void communicate(Obj? params)
   {

    if(this.parent.parent is UiUpdatable)
    {
      (this.parent.parent as UiUpdatable).updateUi(params)
    }
    return
   }

}

