/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using pbpcore
using obix
using pbplogging

const class SearchForHistoryConfig : Configuration
{
  override Obj? invoke(Obj? msg, Str:Obj? options := [:])
  {
    if(msg!=null)
    {
    List cred := options["streetcred"]
    Actor statusHandler := options["statusHandler"]
    Uri href := msg
    ObixClient client := ObixClient(cred[0], cred[1], cred[2])
    try
    {
      ObixObj firstTier := client.read(msg)
      historyExts := firstTier.list.findAll |ObixObj obObj->Bool| {return obObj.contract.toStr.contains("/obix/def/history:")}
      if(historyExts.size > 0)
      {
        historyExts.each |ext|
        {
          ObixObj hisItem := client.read(ext.normalizedHref)
          if(hisItem.has("historyConfig"))
          {
            ObixObj hisConfigItem := client.read(hisItem.get("historyConfig").normalizedHref)
            if(hisConfigItem.has("id") && hisConfigItem.get("id").val.toStr != "")
            {
              Logger.log.info(("/obix/histories"+hisConfigItem.get("id").val.toStr).toUri.toStr)
              statusHandler.send([href.pathOnly,("/obix/histories"+hisConfigItem.get("id").val.toStr).toUri])
            }
          }
        }
        return true
       }
       statusHandler.send([href.pathOnly,"No History Found"])
     }
     catch(Err e)
     {
       statusHandler.send([href.pathOnly,"No History Found"])
       return false
     }
    }
    return null
  }
}
