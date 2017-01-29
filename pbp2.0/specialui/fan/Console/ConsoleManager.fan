/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


abstract class ConsoleManager
{
  abstract File sessionDirectory
  abstract Str name
  abstract Func job
  abstract Opt opt
  virtual List options := [,]

  virtual Void process(List parameters)
  {
    job.callList(parameters)
  }

}
