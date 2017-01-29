/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using airship

class RegisterDeliveries : Command
{
  new make() : super.makeLocale(Pod.of(this), "registerDeliveries")
  {}

  override Void invoked(Event? event)
  {
    PbpAirshipWindow pbpWindow := event.window
    PbpAirship pbpAirship := Service.find(PbpAirship#)
    if(pbpWindow.senderTable.selected.size >0 && pbpWindow.receiverTable.selected.size > 0)
    {
      PackageSender sender := (pbpWindow.senderTable.model as SenderTableModel).rows.get(pbpWindow.senderTable.selected.first)
      PackageReceiver receiver := (pbpWindow.receiverTable.model as ReceiverTableModel).rows.get(pbpWindow.receiverTable.selected.first)
      pbpAirship.register(sender, receiver)
    }
    else
    {
      Dialog.openInfo(event.window,"Please select a sender and receiver")
    }
  }
}
