/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using airship
using haystack
using pbpskyspark
using pbpsql
using pbplogging

@Serializable
const class SqlToSkysparkSender : SkySparkAirshipSender, Logging
{

  @Transient
  const Unsafe connection
  @Transient
  const Unsafe currentPackages := Unsafe([,])

  const Uri sqlConnFile
  const Str:Obj options
  const Str:Uri manifestDirectory

  new make(|This| f)
  {
    f(this)
    connection = Unsafe(SqlConnWrapper.load(File(sqlConnFile)))
  }

  override Void hisWrite()
  {
    info("Starting History Import Check",null,"pbpairship")
    Bool full   := options["hisWriteFullSql"]
    info("Full Sql implementation: $full",null,"pbpairship")
    Bool hybrid := options["hisWriteHybrid"]
    info("Hybrid Sql implementation: $hybrid",null,"pbpairship")
    SqlPackageDeploymentScheme[] schemes := options["hisWrite"]
    Str:Dict[] dictsToPack := [:]

    SqlConnWrapper connection := this.connection.val
    info("Connecting to ${connection.server.host}",null,"pbpairship")

    manifestDirectory.each |manifest, key|
    {
      Str:Str manifestDb := File(manifest).readObj
      schemes.each |scheme|
      {
        scheme.packages.each |pack|
        {
          Str statement := scheme.formMap[pack.id["name"]]
          connection.queryBlocking(statement).each |row|
          {
            Str:Obj responseMap := SqlPackageUtil.getDict(pack, row)
            //TODO: look at response and check timestamp against max timestamp
            if(full)
            {
              try
              {
                target := "point" + responseMap["target"]

                if(manifestDb.containsKey(target) && !dictsToPack.containsKey(manifestDb[target]))
                {
                  dictsToPack[manifestDb[target]] = [responseMap["dict"]]
                }
                else
                {
                  // echo("responseMap[dict]: " + responseMap["dict"])
                  // echo("responseMap[target]: " + target)
                  // echo("manifestDb[responseMap[target]]: " + manifestDb[target])
                  // echo("dictsToPack[manifestDb[responseMap[target]]]: " + dictsToPack[manifestDb[target]])

                  dictsToPack[manifestDb[target]].push(responseMap["dict"])
                }
              }
              catch(Err e)
              {
                err("Error processing history",e,"pbpairship")
              }
            }
            if(hybrid)
            {
              //TODO: look at manually selected Ref's pack those up too....
            }
          }
        }
      }
    }

    //echo(dictsToPack)

    if(dictsToPack.size > 0)
    {
      address :=options["addresses"]
      newPackage := Package{
          it.options=["address":address , "type":"hisWrite"]
          message=dictsToPack
          }
      (currentPackages.val as List).push(newPackage)
    }
  }

  override Bool checkUpdate()
  {
    hisWrite()
    //Add more checks here too
    List currentPackages := this.currentPackages.val
    newupdate := (currentPackages.size > 0)
    if(newupdate)
    {
      info("New update $this",null,"pbpairship")
    }
    return newupdate
  }

  override Package[] getPackages()
  {
    info("Beginning Grab of Packaged From Sql Sender",null,"pbpairship")
    toReturn := [,]
    toReturn.addAll(currentPackages.val)
    (currentPackages.val as List).clear
    return toReturn
  }

}




