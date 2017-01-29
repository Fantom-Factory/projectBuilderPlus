/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using xml
using web

abstract class Conn
{
  abstract Str dis
  abstract Str user
  abstract Str host
  abstract Str? projectName
  abstract Record[] addRecsToProject()
  abstract Obj? connect()
  abstract Bool testConn()
  abstract XElem toXml()
  abstract Void storePass()
  abstract Str[] prefixes

  override Str toStr() {dis}
}
