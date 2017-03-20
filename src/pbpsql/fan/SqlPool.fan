/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore

class SqlPool
{
  SqlConnWrapper[] connPool := [,]
  new make()
  {

  }

  static SqlPool fromProject(Project? project)
  {
    SqlPool sqlPool := SqlPool()
    if(project!=null)
    {
      File[] connFiles := project.connDir.listFiles.findAll |File f->Bool|{return f.ext=="sqlconn"}
      connFiles.each |file|
      {
        sqlPool.connPool.push(SqlConnWrapper.load(file))
      }
    }
    return sqlPool
  }

//Backend
  Void newSqlConn(Str dis, Str host, Str user, Str pass)
  {
    SqlConnWrapper? check := connPool.find |SqlConnWrapper sq -> Bool|{return sq.getDis() == dis}
    if(check == null)
    {
      connPool.push(SqlConnWrapper(dis,host,user,pass))
    }
    return
  }

  SqlConnWrapper? getSqlConn(Str dis)
  {
    return connPool.find |SqlConnWrapper sq -> Bool|{return sq.getDis() == dis}
  }

  Bool removeSqlConn(SqlConnWrapper toremove)
  {
    SqlConnWrapper? check := connPool.find |SqlConnWrapper sq->Bool| {return sq.getDis == toremove.getDis}
    if(check != null)
    {
      connPool.remove(check)
      return true
    }
    else{
      return false
    }
  }

  Str[] listConns()
  {
    toReturn := [,]
    connPool.each |conn| {
      toReturn.push(conn.getDis)
    }
    return toReturn
  }
//Frontend




}
