/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpi
using concurrent

class SaveStatusLabel : GridPane, UiUpdatable
{
  AtomicBool? saveStatus
  Label imageLabel
  Label textLabel
  new make(AtomicBool saveStatus)
  {
    this.saveStatus = saveStatus
    numCols = 2;
    imageLabel = Label{image=PBPIcons.greenDot16}
    textLabel = Label{text="Saved"}
    add(imageLabel)
    add(textLabel)
  }

  override Void updateUi(Obj? obj:=null)
  {
    if(!saveStatus.val)
    {
     imageLabel.image=PBPIcons.orangeDot16
     textLabel.text="Not Saved"
     relayout
     this.parent.relayout
     this.parent.parent.relayout
     //
    }
    else if(saveStatus.val)
    {
      imageLabel.image=PBPIcons.greenDot16
      textLabel.text="Saved"
      relayout
      this.parent.relayout
      this.parent.parent.relayout
    }
  }
}

