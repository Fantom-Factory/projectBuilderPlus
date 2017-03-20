/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using obix
using web
using pbpcore

**
** Wraps a PeristsConn and provided extra functionalities
**
class PbpObixConn
{
  PersistConn conn

  // Where we will locally cache icons pulled from obix server
  static const Uri cacheFolder := Env.cur.homeDir.uri+`resources/obix/`

  ObixClient? client
  ObixObj? lobby
  Str host
  Str user

  new make(PersistConn conn)
  {
    this.conn = conn
    this.host = conn.params["host"]
    this.user = conn.params["user"]
  }

  Void connect()
  {
    //echo(">readlobby")
    client = ObixClient(Uri(host), user, conn.plainPassword)
    //echo(client)
    this.lobby = client.readLobby
    //echo("<readlobby")
  }

  ** Returns the ObixObj root (lobby)
  ObixItem getRoot()
  {
    return ObixItem(lobby, null)
  }

  ** Returns specific ObixObj item
  ObixItem getItem(Uri uri)
  {
    ObixObj obj := client.read(uri)
    return ObixItem(obj, getIcon(obj))
  }

  ** Returns an obix resource (/ord)
  internal Buf getObixRes(Uri uri)
  {
    resUri := lobby.href.parent /*+ "ord?"*/ + uri
    wc := WebClient(resUri)
    wc.reqHeaders["Authorization"] = "Basic " + "$user:$conn.plainPassword".toBuf.toBase64
    data := wc.getIn.readAllBuf
    return data
  }

  internal Uri? getIcon(ObixObj obj)
  {
    if(obj.icon == null)
      return null

    path := obj.icon.toStr
    path = path[path.indexr("://")+3 .. -1]
    cacheUri := cacheFolder + path.toUri
    iconFile := File(cacheUri)

    if( ! iconFile.exists)
    {
      data := getObixRes(obj.icon)
      iconFile.create.out.writeBuf(data).close
    }

    return iconFile.uri
  }


  override Str toStr()
  {
      return conn.name
  }
}

**
** An Obix object with a few extra features
**
class ObixItem
{
  ObixObj obj
  Uri? iconUri
  Str name

  new make(ObixObj obj, Uri? iconUri)
  {
    this.obj = obj
    this.iconUri = iconUri
    name := obj.displayName
    if(name == null) name = obj.name
    if(name == null) name = obj.href.path[-1]
    this.name = name
  }

  Bool isHis()
  {
    return obj.contract.toStr.contains("obix:History")
  }

  Bool isPoint()
  {
    return obj.contract.toStr.contains("obix:Point")
  }
}
