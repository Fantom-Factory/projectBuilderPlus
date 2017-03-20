/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore

**
** Wraps a PersistConn and provided extra functionalities
**
class PbpFileConn
{
  PersistConn conn

  new fromConn(PersistConn conn)
  {
    this.conn = conn
  }

  new make(Uri uri, Str format, FileMap[] fileMaps)
  {
    name := Regex<|[^\w]+|>.split(uri.toStr).join("")
    this.conn = PersistConn.makeNew(name, "pwd", [ "uri" : uri, "format" : format, "maps" : fileMaps ])
  }

  new makeCopy(PbpFileConn other, FileMap[]? newFileMaps := null) : this.make(other.uri, other.format, newFileMaps ?: other.fileMaps)
  {}

  Uri uri()
  {
    return (Uri)conn.params["uri"]
  }

  Str fileName()
  {
    return uri.name
  }

  Str format()
  {
    return (Str)conn.params["format"]
  }

  FileMap[] fileMaps()
  {
    return (FileMap[])conn.params["maps"]
  }

  private static const Str FILE_EXT := "file"

  **
  ** Save this connection in the given project
  **
  Void saveToProject(Str projectName)
  {
    conn.saveToProject(projectName, FILE_EXT)   
  }

  **
  ** Load all connections of this type (matching fileExt) of this project
  **
  static PbpFileConn[] loadFromProject(Str projectName)
  {
    return PersistConn.loadFromProject(projectName, FILE_EXT).map { PbpFileConn(it) }
  }

  **
  ** Delete a saved connection file
  **
  Void deleteFromProject(Str projectName)
  {
    PersistConn.deleteFromProject(projectName, conn.name, FILE_EXT)
  }
}
