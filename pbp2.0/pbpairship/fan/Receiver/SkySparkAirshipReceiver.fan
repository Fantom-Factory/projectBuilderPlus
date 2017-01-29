/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using airship
using pbpskyspark
using pbplogging
using haystack
using concurrent
using projectBuilder

**
** Package Options - (Package.options[] mappings for the settings)
** "address" -- This has the connection details
** "type" -- can be "hisWrite", "recCommit", "recUpdate", or "recRemove", determines the function
** "historyMap" -- This contains the Dicts
**
@Serializable
const class SkySparkAirshipReceiver : PackageReceiver, Logging
{
    @Transient
    private const LicenseInfo licenseInfo

    new make(LicenseInfo licenseInfo)
    {
      this.licenseInfo = licenseInfo
    }

  override Void onReceive(Package package)
  {
    info("Receiving new package",null,"pbpairship")
    File address := File(package.options["address"])
    SkysparkConn conn := SkysparkConn.fromXml(address, licenseInfo)
    info("Writing package to conn.host",null,"pbpairship")
    Str packageType := package.options["type"]
    switch(packageType)
    {
      case "hisWrite":
        Str:Dict[] historyMap := package.message
        historyMap.each |dicts, target|
        {
          targetRef := "@${Ref.fromStr(target)}"

          info("Reading rec info: $targetRef", null, "pbpairship")

          recGrid := conn.eval("keepCols(readAll(id == $targetRef), [\"id\",\"tz\",\"hisEnd\"])")

          if (recGrid.isErr || recGrid.first?.get("id") == null) err("$targetRef not found in SkySpark")

          recRow := recGrid.first
          DateTime? hisEnd := recRow?.get("hisEnd")
          Str tz := recRow["tz"]

          info("  Exporting history values...", null, "pbpairship")
          count := 0
          dicts.each |dict|
          {
            value := dict["val"]
            ts := ((DateTime)dict["ts"]).toTimeZone(TimeZone(tz))

            cmd := "hisWrite({val:$value, ts: dateTime(${ts->date},${ts->time},\"${ts->tz}\") }, $targetRef)"
            Grid result := conn.eval(cmd)

            if(result.isErr){
              err("Error evaluating: $cmd\n"+result.meta.toStr,null)
            }

            count++;
          }
          info("  $count values exported.", null, "pbpairship")
        }
        return
     case "recCommit":
     return
     case "recUpdate":
     return
     case "recRemove":
     return
    }
    return
  }
}
