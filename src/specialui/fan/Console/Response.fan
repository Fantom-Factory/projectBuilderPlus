/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

@Serializable
class Response
{
  Str text
  Error[] children
  new make(|This| f)
  {
    f(this)
  }
}
