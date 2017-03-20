/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using util
using pbplogging

**
** Generic Connection object that can be saved/load via serialization
**
@Serializable
final class PersistConn : Logging
{
  ** Name for this connection
  const Str name

  ** Password (encrypted)
  private const Str password

  ** All other connections params such as user, host etc ...
  const Str:Obj params

  new make(|This| f) {f(this); debug(this.toStr)}

  new makeNew(Str name, Str plainPassword, Str:Obj params)
  {
    this.name = name
    this.password = encrypt(plainPassword)
    this.params = params
  }

  ** return password decrypted
  Str plainPassword()
  {
    return decrypt(password)
  }

  internal Str encrypt(Str plain)
  {
    // Note: hard coded secretKey, we could ask the user to pick one instead (safer))
    return Crypto().encode(plain, "##betterthanNothing!")
  }

  internal Str decrypt(Str pass)
  {
    return Crypto().decode(pass, "##betterthanNothing!")
  }

  ** Save this connection to out
  Void save(File f)
  {
    try
      f.writeObj(this)
    catch(Err e){Logger.log.err("Save error",e)}
  }

  ** Load connection object from file
  static PersistConn? load(File f)
  {
    PersistConn? conn
    try
      conn = f.readObj()
    catch(Err e){Logger.log.err("Load error")}
    Logger.log.info("loaded conn from : $f.osPath")
    return conn
  }

  ** Save this connection in the given project
  ** fileExt: File extension for this kind of connection (must be unique per connection type)
  Void saveToProject(Str projectName, Str fileExt)
  {
    f := FileUtil.getConnDir(projectName).createFile(name+"."+fileExt)
    Logger.log.info("Saving conn file: $f.osPath") 
    save(f)
  }


  ** Load all connections of this type (matching fileExt) of this project
  ** fileExt : File extension for this kind of connection (must be unique per connection type)
  static PersistConn[] loadFromProject(Str projectName, Str fileExt)
  {
    PersistConn[] results := [,]
    FileUtil.getConnDir(projectName).listFiles.each
    {
      if(it.ext.lower == fileExt.lower)
      {
        conn := load(it)
        if(conn != null)
          results.add(conn)
      }
    }
    return results
  }

  ** Delete a saved connection file
  static Void deleteFromProject(Str projectName, Str connName, Str fileExt)
  {
    f := FileUtil.getConnDir(projectName).createFile(connName+"."+fileExt)
    if(f.exists)
    {
      Logger.log.info("Deleting conn file: $f.osPath")
      f.delete
    }
  }

  static Void main()
  {
    Logger.log.info(">")
    PersistConn test := PersistConn.makeNew("name", "pass", [:])
    File f := File(`/tmp/test`)
    test.save(f)
    conn := PersistConn.load(f)
    Logger.log.info("Conn: $conn")
  }
}
