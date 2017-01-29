/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore
using web
using util
using fanr

class RepoAuth
{
  Str url
  Str user
  Str password
  Bool ok := true
  Str:Obj? headers := [:]
  new make(|This| f)
  {
    f(this)
    password = Crypto().encode(password, "sillyrabbit")
  }

  Void auth()
  {
    headers["Fanr-Username"] = user
    headers["Fanr-SecretAlgorithm"] = "SALTED-HMAC-SHA1"
    headers["Fanr-SignatureAlgorithm"] = "HMAC-SHA1"
    authStr := url+"/auth/?${user}"
    try
    {
    authClient := WebClient(authStr.toUri)
    respStr := authClient.getStr
    Map map := JsonInStream(respStr.in).readJson
    Str salt := map["salt"]
    Buf secret := Buf().print("$user:$salt").hmac("SHA-1", Crypto().decode(password, "sillyrabbit").toBuf)
    headers["Fanr-Signature"] = secret
    }
    catch(Err e)
    {
      echo(e.traceToStr)
      this.ok = false
      return
    }
  }

  Void setHeaders(WebClient client)
  {
      client.reqHeaders["Fanr-Username"] = headers["Fanr-Username"]
      client.reqHeaders["Fanr-SecretAlgorithm"] = headers["Fanr-SecretAlgorithm"]
      client.reqHeaders["Fanr-SignatureAlgorithm"] = headers["Fanr-SignatureAlgorithm"]
      client.reqHeaders["Fanr-Ts"] = DateTime.nowUtc().toStr
      s := toSignatureBody(client.reqMethod, client.reqUri, client.reqHeaders)
      secret := headers["Fanr-Signature"]
      signature := s.hmac("SHA-1", secret).toBase64
      client.reqHeaders["Fanr-Signature"] = signature
  }

   Buf toSignatureBody(Str method, Uri uri, Str:Str headers)
  {
    s := Buf()
    s.printLine(method.upper)
    s.printLine(uri.encode.lower)
    keys := headers.keys.findAll |key|
    {
      key = key.lower
      return key.startsWith("fanr-") && key != "fanr-signature"
    }
    keys.sort.each |key|
    {
      s.print(key.lower).print(":").printLine(headers[key])
    }
    return s
  }
}
