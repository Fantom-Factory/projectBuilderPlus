/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using haystack
using airship

**
** Package Options - (Package.options[] mappings for the settings)
** "address" -- This has the connection details
** "type" -- can be "hisWrite", "recCommit", "recUpdate", or "recRemove", determines the function
** "historyMap" -- This contains the Dicts
**
abstract const class SkySparkAirshipSender : PackageSender
{
  abstract Void hisWrite()
}
