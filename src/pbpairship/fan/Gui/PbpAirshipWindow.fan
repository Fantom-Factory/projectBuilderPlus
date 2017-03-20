/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpgui
using pbpcore
using projectBuilder

class PbpAirshipWindow : PbpWindow
{
  Str:Obj? options

  EdgePane mainWrapper := EdgePane{}
  ButtonGrid commandGrid := ButtonGrid{numCols=1}
  ButtonGrid buttonGrid := ButtonGrid{numCols=1}
  SashPane tablePane := SashPane{orientation=Orientation.vertical}
  Table senderTable := Table{model=SenderTableModel()}
  Table receiverTable
  new make(Window? parentWindow, Str:Obj? options, LicenseInfo licenseInfo) : super(parentWindow)
  {
    this.options = options
    this.receiverTable = Table() { model=ReceiverTableModel(licenseInfo) }
  }

  override Obj? open()
  {
    size=Size(525,440)
    tablePane.add(EdgePane{
      top=Label{text="Senders"};
        center=senderTable})
    tablePane.add(EdgePane{
      top=Label{text="Receivers"};
        center=receiverTable})
    buttonGrid.add(Button{text="Close"; onAction.add|e|{e.window.close}})
    commandGrid.add(Label{})

    commandGrid.add(Button(NewSender(options["projectBuilder"])))
    commandGrid.add(Button(NewReceiver(options["projectBuilder"])))
    commandGrid.add(Button(RegisterDeliveries()))
    commandGrid.add(Button(StartService(options["projectBuilder"])))
    commandGrid.add(Button(StopService(options["projectBuilder"])))
    mainWrapper.center = tablePane
    mainWrapper.right = commandGrid
    mainWrapper.bottom = buttonGrid
    content = mainWrapper
    super.open
    return null
  }


}
