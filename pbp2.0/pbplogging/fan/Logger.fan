/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using util

**
** Centralized Logging
** Log to projectbuilder-{YYMM}.log & console
** Min levels going to console and file can be configured in build.props
**
const class Logger : FileLogger
{
  ** minimum level to log in log file
  static const LogLevel minLevel := LogLevel(Env.cur.index("bass.logger.minlevel").first)

  // default log
  static const Log log := Log.get("pbp")

  new make(|This|? that) : super(that)
  {
    log.warn("Started logging to ${dir}")
  }

  Void append(LogRec? rec)
  {
    if(rec == null)
    {
      log.info("Was requested to log a null LogReg - Ignoring")
    }
    if(rec.level.ordinal >= minLevel.ordinal)
    {
      writeLogRec(rec)
    }

  }
}
