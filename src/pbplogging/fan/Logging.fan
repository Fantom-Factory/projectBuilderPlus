/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


**
** Centralized Logging
** Convenience mixin to get the methods via "inheritance", as local methods
**
mixin Logging
{
  Void debug(Str msg, Err? err := null, Str? logName := null)
  {
    if(logName != null)
      Log.get(logName).debug(msg, err)
    else
      Logger.log.debug(msg, err)
  }
  
  Void info(Str msg, Err? err := null, Str? logName := null)
  {
    if(logName != null)
      Log.get(logName).info(msg, err)
    else
      Logger.log.info(msg, err)
  }
  
  Void warn(Str msg, Err? err := null, Str? logName := null)
  {
    if(logName != null)
      Log.get(logName).warn(msg, err)
    else
      Logger.log.warn(msg, err)
  }
  
  Void err(Str msg, Err? err := null, Str? logName := null)
  {
    if(logName != null)
      Log.get(logName).err(msg, err)
    else
      Logger.log.err(msg, err)
  }
}
