/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using web
using fwt
using gfx
using pbplogging

class RepoConn
{
  Uri repoUrl
  RepoAuth? repoAuth
  new make(|This| f)
  {
    f(this)
    if(this.repoAuth!=null)
    {
      repoAuth.auth
    }
  }

**
**Returns the InStream for the contents of pbp repo, if IOErr show Warning Dialog and return null
**
  InStream? queryRepo(Program program)
  {
    Str request := "${repoUrl.toStr}query?${program.name}"
    return requestToRepo(request);
  }

  InStream? getVersion(Program program)
  {
    Str request := "${repoUrl.toStr}pod/${program.name}/${program.version}"
    return requestToRepo(request);
  }

  InStream? requestToRepo(Str request)
  {
    WebClient reqClient := WebClient(request.toUri)
    if(repoAuth!=null)
    {
      if(repoAuth.ok == false)
      {
        throw Err("Auth failed")
        return null
      }
      repoAuth.setHeaders(reqClient)
    }
    try
    {
      InStream resp := reqClient.getIn
      return resp
    }
    catch(IOErr err)
    {
      Logger.log.err("Request to repo failed", err)
      Dialog.openErr(null,"Request Failed, please check your internet connection and try again.",Label{text=reqClient.resStr+"\n"+err.traceToStr})
      if(reqClient.resStr.contains("time"))
      {
        Dialog.openErr(null, "Please check your system time", Label{text=reqClient.resStr})
      }
      echo(reqClient.resStr)
      return null
    }
    catch(Err err)
    {
      Logger.log.err("Request to repo failed", err)
      Dialog.openErr(null,"Failed, Please try again.",Label{text=err.traceToStr})
      return null
    }
  }

}
