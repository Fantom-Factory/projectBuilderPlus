/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using sql

class SqlUtil{

  static SqlConn getConn(SqlServer server)
  {
    return SqlConn.open(server.host, server.user, server.pass)
  }

  static SqlDatabase? getDatabase(SqlServer server)
  {
    if(server.host.lower.contains("mysql")) {
      return SqlDatabase{ name = server.host.split('/')[3]; children = [,]; parent = server }
    } else if(server.host.lower.contains("sqlserver")) {
      //getting database name
      dbname := server.host.split(';').find |Str s->Bool| {
        return s.contains("databaseName") || s.contains("database")
      }
      return SqlDatabase{ name = dbname.split('=')[1] ; children = [,]; parent = server }
    }
    return null
  }

  static Bool isMysql(SqlServer server) {
    return server.host.lower.contains("mysql")
  }

  static Bool isMicrosoftSql(SqlServer server) {
    return server.host.lower.contains("sqlserver")
  }

   static SqlConn getDatabaseConn(SqlDatabase database)
  {
    return getConn(SqlServer{host=getNormalizedHost(database.parent)+"/$database.name"; user=(database.parent as SqlServer).user; pass=(database.parent as SqlServer).pass; children=[,]; parent=database.parent})
  }

  static Str getNormalizedHost(SqlServer server)
  {
     if(server.host.split('/').size >= 4)
     {
       //Make this a utility
        prox := [,]
        prox.push(server.host.split('/')[0])
        prox.push(server.host.split('/')[1])
        prox.push(server.host.split('/')[2])
        Str newhost := prox.join("/")
        return newhost
     }
     else
     {
       return server.host
     }
  }

}
