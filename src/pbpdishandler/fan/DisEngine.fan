/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore
using pbpgui
using fwt
using gfx

class DisEngine
{
  private DisFunc[] funcs

  new make(DisFunc[] funcs)
  {
    this.funcs = funcs
  }

  Record[] execute(PbpDatabase database)
  {
    return executeFor(Record#, database)
  }

  Record[] executeFor(Type classMapType, PbpDatabase database)
  {
    Record[] toReturn := [,]
    Map allRecs := database.getClassMap(classMapType)

    allRecs.each |rec, id|
    {
      Record working := rec
      funcs.each |func|
      {
        working = func.invoke(working)
      }
      toReturn.push(working)
    }

    return toReturn
  }

}
