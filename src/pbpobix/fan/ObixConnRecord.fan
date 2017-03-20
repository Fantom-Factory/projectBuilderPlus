/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore

const class ObixConnRecord : Record
{
  new make(|This| f) : super(f) {
    /*
    obixConn: required marker tag
    obixLobby: the absolute URI of the server's lobby (should end in a trailing slash)
    username: user name for authentication
    password: must have password stored in password db for connector's Ref
    */
  }
}
