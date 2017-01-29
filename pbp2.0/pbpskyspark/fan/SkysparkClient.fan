/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using web
using projectBuilder
using pbplogging
using haystack::ApiAuth as AAuth
using haystack::AuthErr

**
** Managed Skyspark Client (REST) that support auhentication and retains the cookie for furter queries
**
class SkysparkClient
{
  **
  ** Open with URI of project such as "http://host/api/myProj/".
  ** Throw IOErr for network/connection error or `AuthErr` if
  ** credentials are not authenticated
  **
  static SkysparkClient open(Uri uri, Str username, Str password)
  {
    // normalize and check URI
    uri = uri.plusSlash
    if (uri.scheme != "http") throw ArgErr("Only http: URIs supported: $uri")

      // authenticate with server
    cookie := AAuth(uri, username, password).auth

    // we're in
    return make(uri, cookie)
  }

  internal Void validateSas(Str secret, LicenseInfo licenseInfo)
  {
    h := uri.host

    hosts := licenseInfo.sasHosts
    if( ! licenseInfo.unlimitedSas && ! hosts.isEmpty) // if not SAS then it's standalone, no check to do
    {
      //Logger.log.info("Checking sas license !")
      // part1 : check host name
      if(!hosts.containsKey(h))
      {
        Logger.log.info("Your SAS license does not allow connection to $h")
        throw AuthErr("Your SAS license does not allow connection to $h")
      }

      //part2: verify against skyspark extension
      salt := Buf.random(16).toHex

      c := WebClient(uri+`ext/PbpSasLicenseExt`)
      c.reqHeaders["Cookie"] = cookie
      sids := hosts.vals.join(",")
      c.postForm(["salt":salt, "sids":sids])
      receivedHash := c.resIn.readAllStr

      salted := salt.toBuf.hmac("SHA1", "Authorized".toBuf).toBase64
      hash := Buf().print(salted).hmac("SHA-1", secret.toBuf).toBase64

      if(hash != receivedHash)
      {
        Logger.log.info("SAS connection was not authorized by $h")
        throw AuthErr("SAS connection was not authorized by $h")
      }
      // Ok we are good
    }
  }

  private new make(Uri uri, Str cookie)
  {
    this.uri = uri
    this.cookie = cookie
  }

  //////////////////////////////////////////////////////////////////////////
  // Identity
  //////////////////////////////////////////////////////////////////////////

  **
  ** URI of project path such as "http://host/api/myProj/".
  ** This URI always ends in a trailing slash.
  **
  const Uri uri
  private const Str cookie
}


**************************************************************************
** ApiAuth
**************************************************************************

**
** ApiAuth is used to authenticate a user/password combination using
** the REST API authentication mechanism.
**
@NoDoc
class ApiAuth
{
  **
  ** Construct with a protected URI space such as "/api/{proj}"
  **
  new make(Uri uri, Str user, Str pass)
  {
    this.uri  = uri
    this.user = user
    this.pass = pass
  }

  **
  ** Authenticate the username, password against the URI.  If successful
  ** then return the session cookie.  If authentication failed then throw
  ** AuthErr.
  **
  Str auth()
  {
    readAuthUri
    if (cookie != null) return cookie
      readAuthInfo
    computeDigest
    authenticate
    return cookie
  }

  private Void readAuthUri()
  {
    // make request to URI with redirects disabled
    c := WebClient(uri)
    c.followRedirects = false
    send(c, false, null)

    // 4xx or 5xx
    if (c.resCode % 100 >= 4) throw IOErr("HTTP error code: $c.resCode")

      // if client returned 200, then it is not running with security
    if (c.resCode == 200) { this.cookie = "fanws:test"; return }

      // get URI from required header
    this.authUri = c.resHeaders["Folio-Auth-Api-Uri"]   ?: throw AuthErr("Missing 'Folio-Auth-Api-Uri' header")
  }

  private Void readAuthInfo()
  {
    c := WebClient(uri + authUri.toUri  + `?$user`)
    response := send(c, true, null)
    this.authInfo = parseAuthProps(response)
  }

  private Void computeDigest()
  {
    this.nonce = authInfo["nonce"] ?: throw Err("Missing 'nonce' in auth info")
    this.salt  = authInfo["userSalt"] ?: throw Err("Missing 'userSalt' in auth info")

    // compute salted hmac
    hmac := Buf().print("$user:$salt").hmac("SHA-1", pass.toBuf).toBase64

    // now compute login digest using nonce
    this.digest = "${hmac}:${nonce}".toBuf.toDigest("SHA-1").toBase64
  }

  private Void authenticate()
  {
    // post back to auth URI
    c := WebClient(uri + authUri.toUri  + `?$user`)
    response := send(c, true, "nonce:$nonce\ndigest:$digest")

    if (c.resCode != 200) throw AuthErr("Authentication failed")

      info := parseAuthProps(response)
    this.cookie = info["cookie"] ?: throw Err("Missing 'cookie'")
  }

  private static Str:Str parseAuthProps(Str text)
  {
    map := Str:Str[:]
    text.splitLines.each |line|
    {
      line = line.trim
      if (line.isEmpty) return
        colon := line.index(":")
      map[line[0..<colon].trim] = line[colon+1..-1].trim
    }
    return map
  }

  private Str? send(WebClient c, Bool get, Str? post)
  {
    try
    {
      // if posting, translate to body buffer and get web client setup
      Buf? body
      if (post != null)
      {
        body = Buf().print(post).flip
        c.reqMethod = "POST"
        c.reqHeaders["Content-Type"] = "text/plain; charset=utf-8"
        c.reqHeaders["Content-Length"] = body.size.toStr
      }

      // debug dump request
      if (debug)
      {
        method := post == null ? "GET" : "POST"
        echo("$method $c.reqUri.relToAuth HTTP/1.1")
        echo("Host: $c.reqUri.host")
        c.reqHeaders.each |v, k| { echo("$k: $v") }
        echo
        if (post != null) { echo(post); echo }
        }

      // make request
      if (post == null)
      {
        c.writeReq.readRes
      }
      else
      {
        c.writeReq
        c.reqOut.writeBuf(body).close
        c.readRes
      }

      // read response
      response := get && c.resCode == 200 ? c.resIn.readAllStr : null

      // debug dump response
      if (debug)
      {
        echo("HTTP/1.1 $c.resCode $c.resPhrase")
        c.resHeaders.each |v, k| { echo("$k: $v") }
        echo
        if (response != null) { echo(response); echo }
        }

      return response
    }
    finally c.close
    }

  private static const Bool debug := false

  private const Uri uri            // constructor
  private const Str user           // constructor
  private const Str pass           // constructor
  private Str? authUri             // readAuthApiUri
  private Str:Str authInfo := [:]  // readAuthApiInfo
  private Str? nonce               // computeDigest
  private Str? salt                // computeDigest
  private Str? digest              // computeDigest
  private Str? cookie              // authenticate
}
