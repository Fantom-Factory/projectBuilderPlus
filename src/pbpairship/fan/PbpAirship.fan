/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using airship
using pbplogging
using fwt
using gfx

const class PbpAirship : Airship, Logging
{
  new make(AirshipConfig config) : super(config)
  {

  }

  override Void register(PackageSender sender, PackageReceiver receiver)
  {
    info("Registering.. Sender: ${sender.id} to Receiver: ${receiver}",null,"pbpairship")
    try
    {
    super.register(sender, receiver)
    }
    catch(Err e)
    {
      err("Error Registering",e,"pbpairship")
    }
     info("Registering.. Sender: ${sender.id} to Receiver: ${receiver} .. Complete",null,"pbpairship")
     Dialog.openInfo(Desktop.focus.window, "Registering Sender: ${sender.id} to Receiver: ${receiver} is Complete")
     return
  }

}
