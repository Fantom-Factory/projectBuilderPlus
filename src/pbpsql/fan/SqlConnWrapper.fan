/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using fwt
using gfx
using sql
using spui
using xml
using pbpcore
using pbplogging

class SqlConnWrapper
{
  Str dis
  public Label statusLabel
  Bool walked := false
  SqlConnWrapperActor worker
  SqlServer server
  SqlConsole manager
  Table resultTable
  Tree serverTree
  Console console
  Obj? rooter
  Str targetDbName := ""
  PaginateControllerPane paginator
  new make(Str dis, Str host, Str user, Str pass)
  {
    this.dis = dis

    server = SqlServer{
     it.host = host
     it.user = user
     it.pass = pass
     children = [,]
     }
    paginator = PaginateControllerPane(this)
    serverTree = Tree {}
    statusLabel = Label{text="Status: idle"}
    resultTable = Table{model = SqlTableModel()}
    worker = SqlConnWrapperActor(statusLabel,resultTable, null, ["paginator":paginator])
    manager = SqlConsole(this)
    console = manager.getConsole()
    targetDbName = SqlUtil.getDatabase(server).name
    rooter = SqlUtil.getDatabase(server)
  }

  Widget getConsoleWrapper()
  {
    return console.getWrapper([126,32])
  }

  Str getDis()
  {
    return dis
  }

  Void initScript(Bool full := true)
  {
     Str targUser := server.user

     //Initialization Script
     //Get all the information we can NOW!
     if(targUser == "root" && full)
     {
     Tasklist tasklist := Tasklist()
     //Script to grab all databases
     SqlConn sqlConn := SqlUtil.getConn(server)
     databases := SqlDatabase[,]
     Future[] futures := [,]
     SqlDatabase[] walkedDbList := [,]
     sqlConn.sql("show databases").query.each |database|
     {
       databases.push( SqlDatabase{name = database.get(database.cols.first).toStr; children =[,]; parent=server} )
     }

     databases.each |database, loc|
     {
       Task task := Task{
          val = 1
          parameters = [database, SqlDatabaseWalker()]
          name = "Walking ${database.name}"
          job = |SqlDatabase db, SqlDatabaseWalker walker->Future| {
            return walker.send([db])
          }
       }
       tasklist.add(task)
     }

     tasklist.start
     futures.addAll(tasklist.response)

     futures.each |db|
     {
       if(db.get->get.typeof != SqlErr#) //db->get->get!=null &&
       {
         walkedDbList.push(db.get->get)
       }
     }

     server = SqlServer{
       it.host = server.host
       it.user = server.user
       it.pass = server.pass
       children = walkedDbList
     }
     sqlConn.close
     rooter = server
     }
     else
     {
       SqlConn sqlConn := SqlUtil.getConn(server)
       SqlDatabase database := SqlUtil.getDatabase(server)
       SqlTable[] tables := [,]
       if(SqlUtil.isMysql(server)) {
         sqlConn.sql("show tables").query.each |table, index|
         {
           SqlCol[] cols := [,]
           tables.push(SqlTable{ name = table.get(table.cols.first); children = [,]; parent = database})
           Row[] rows := sqlConn.sql("SELECT * from ${tables.peek.name}").query
           if(rows.size > 0)
           {
             rows.first.cols.each |col|
             {
               cols.push(SqlCol{name=col.name; parent=tables.peek})
             }
           tables[index] = SqlTable{ name = tables[index].name; children = cols; parent = database}
           }
         }
       } else if(SqlUtil.isMicrosoftSql(server)) {
           sqlConn.sql("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES").query.each |table, index|
           {
             SqlCol[] cols := [,]
             tables.push(SqlTable{ name = table.get(table.col("TABLE_NAME")); children = [,]; parent = database})
             Row[] rows := sqlConn.sql("SELECT COLUMN_NAME from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = '${tables.peek.name}'").query
             if(rows.size > 0)
             {
               rows.each |row|
               {
                 cols.push(SqlCol{name=row.get(row.cols.first); parent=tables.peek})
               }
               tables[index] = SqlTable{ name = tables[index].name; children = cols; parent = database}
             }
           }
       } else {
         return
       }

       SqlDatabase fullDb := SqlDatabase{name = database.name; children = tables; parent = database.parent}
       rooter = fullDb
       sqlConn.close
     }

     walked = true
  }

  Void ping(){
    worker.send(["ping",server,""])
  }
  Void execute(Str statement){
    worker.send(["exectute",server,statement])
  }

  Void query(Str statement){
    worker.send(["query",server,statement])
  }

  Void queryUnseen(Str statement){
    worker.send(["queryUnseen", server,statement])
  }

  SqlRow[] queryBlocking(Str loadedStatement)
  {
    Str statement := Regex.fromStr(":::").split(loadedStatement).get(0)
    Str targetdb := Regex.fromStr(":::").split(loadedStatement).get(2)

    SqlConn connection := (SqlUtil.isMicrosoftSql(server))
                          ? SqlConn.open(server.host,server.user, server.pass)
                          : SqlUtil.getDatabaseConn(SqlDatabase{name=targetdb; children =[,]; parent=server})

    Log.get("pbpsql").info("Querying ${server.host}")
    tableVals := SqlRow[,]
    result := connection.sql(statement).prepare.query
    if(result.size >0)
     {
       result.each |row|
       {
         tableVals.push(SqlRow(row))
       }
     }
      return tableVals
  }

  Table getResultTable(Window? parent := null)
  {
    resultTable = Table{model=SqlTableModel()}
    worker = SqlConnWrapperActor(statusLabel,resultTable, parent,["paginator":paginator])
    manager = SqlConsole(this)
    console = manager.getConsole()
    return resultTable
  }

  Label getStatusLabel(Window? parent := null)
  {
    statusLabel = Label{text="Status: idle"}
    worker = SqlConnWrapperActor(statusLabel,resultTable, parent, ["paginator":paginator])
    manager = SqlConsole(this)
    console = manager.getConsole()
    return statusLabel
  }

  PaginateControllerPane getPaginator(Window? parent := null)
  {
    paginator = PaginateControllerPane(this)
    worker = SqlConnWrapperActor(statusLabel, resultTable, parent, ["paginator":paginator])
    manager = SqlConsole(this)
    console = manager.getConsole()
    return paginator
  }

  Tree getServerTree()
  {
    serverTree = Tree{
      model=SqlTreeModel(rooter)
      multi=true
      onSelect.add |e|
        {
          Obj? walker := null
          Str[] multiCol := [,]
          if((e.widget as Tree).selected.size > 1)
          {
            (e.widget as Tree).selected.findAll |Obj? obj -> Bool| {return obj is SqlCol}.each |SqlCol col|
            {
              multiCol.push(col.name)
            }
            walker = e.data
          }
          else
          {
          walker = e.data
          }

          SqlServer? server :=  null
          SqlDatabase? database := null
          SqlTable? table := null
          SqlCol? column := null

          while(walker != null)
          {
            switch(walker.typeof)
            {
              case SqlServer#:
                server = walker
              case SqlDatabase#:
                database = walker
              case SqlTable#:
                table = walker
              case SqlCol#:
                column = walker
            }
            walker = walker->parent
          }
        SqlServer newserver := SqlServer{
          host = SqlUtil.getNormalizedHost(server) + "/${database.name}"
          user = server.user
          pass = server.pass
          children = [,]
        }
        //RESET TARGET DB HERE, PASS CONSOLE MANAGER THE NEW DBNAME VIA SQLOPT
        targetDbName = SqlUtil.getDatabase(newserver).name
        manager.opt = SqlOpt{opts=[targetDbName]}
        if(table != null)
        {
          Str columnStr := (column == null? "*" : (multiCol.size > 0 ? multiCol.join(",") : column.name))
          console.addTextCommand(TextCommand{text="SELECT $columnStr from ${table.name}"; ts = Time.now.toStr; opts=targetDbName; children=[,]})
        }
        else if(table == null)
        {
          console.addTextCommand(TextCommand{text="show tables"; ts=Time.now.toStr; opts=targetDbName; children=[,]})
        }
        }
      }
    return serverTree
  }

/*
  XElem toXml()
  {

  }
*/
  Void save(Str projectName)
  {
    PersistConn persistConn := PersistConn.makeNew(this.dis, server.pass, ["host":server.host, "user":server.user])
    persistConn.saveToProject(projectName, "sqlconn")
  }

  Void delete(Str projectName)
  {
    PersistConn persistConn := PersistConn.makeNew(this.dis, server.pass, ["host":server.host, "user":server.user])
    PersistConn.deleteFromProject(projectName,persistConn.name,"sqlconn")
  }

  static SqlConnWrapper load(File sqlConnFile)
  {
    PersistConn persistConn := PersistConn.load(sqlConnFile)
    return SqlConnWrapper(persistConn.name, persistConn.params["host"], persistConn.params["user"], persistConn.plainPassword)
  }


}


const class SqlConnWrapperActor: Actor
{
 const Watcher watcherCols := Watcher()
 const Watcher watcherRows := Watcher()
 const Watcher newQuery := Watcher()

 const Str handleStatus := Uuid().toStr
 const Str handleTable := Uuid().toStr
 const Str handleWindow := Uuid().toStr
 const Str ping := "ping"
 const Str execute := "execute"
 const Str query := "query"
 const Str queryUnseen := "queryUnseen"
 const Str idle := "idle"
 const Str ioerr := "ioconn"
 const Str sqlerr := "sqlerr"
 const Str oerr := "oerr"
 const Str liveconn := "liveconn"
 const Str emptyresp := "emptyresp"

 const AtomicRef colVals := AtomicRef([,].toImmutable)
 const AtomicRef rowVals := AtomicRef([,].toImmutable)
 const AtomicRef querVal := AtomicRef("".toImmutable)
 const Actor paginatorHandler
 new make(Obj? statusTracker, Obj? resultTable, Obj? parentWindow, Map options) : super(ActorPool())
 {
   paginatorHandler = PaginatorHandler(options["paginator"], this.pool)

   Actor.locals[handleStatus] = statusTracker
   Actor.locals[handleTable] = resultTable
   Actor.locals[handleWindow] = parentWindow
 }

 override Obj? receive(Obj? data)
 {

   Duration startTime := Duration.now
   Bool nodata := false
   List thedata := data
   Str instruction := thedata[0]
   SqlServer server := thedata[1]
   Str statement := Regex.fromStr(":::").split(thedata[2]).get(0)
   Str targetdb := Regex.fromStr(":::").split(thedata[2]).get(2)
   Obj? result := null;

   try
   {
   SqlConn? connection := null
   if(SqlUtil.isMicrosoftSql(server)) {
    connection = SqlConn.open(server.host,server.user, server.pass)
   } else {
    connection = SqlUtil.getDatabaseConn(SqlDatabase{name=targetdb; children =[,]; parent=server})
   }
   Desktop.callAsync |->| { updateStatus(instruction) }
   switch(instruction)
   {
     case ping:
         result = [connection.meta.productVersionStr,connection.meta.tables]
         Log.get("pbpsql").info("Worker ${this.hash} pinging ${server.host}")
     case execute:
         result = connection.sql(statement).execute
         Log.get("pbpsql").info("Actor ${this.hash} executing with ${server.host}")
     case query:
         Log.get("pbpsql").info("Worker ${this.hash} querying ${server.host}")

         result = connection.sql(statement).prepare.query

         //TODO: Pagination support here
         if((result as List).size >0)
         {
           Int pages := 1
           if((result as List).size > 10000)
           {
             Int totalsize := (result as List).size
             pages = (totalsize / 10000)
             if(totalsize-(10000*pages)>0){pages++}
           }
           tableVals := SqlRow[,]
           if(pages > 1)
           {
             pageQueries := [,]
             //Paginate
             pages.times |index|
             {
               Str newStatement := statement+" limit ${index*10000},10000"
               Str newLoadedStatement := newStatement+":::"+"${Time.now()}"+":::"+targetdb
               pageQueries.push(newLoadedStatement) //TODO
             }
             Str newStatement := statement+" limit ${(pages+1)*10000},10000"
             Str newLoadedStatement := newStatement+":::"+"${Time.now()}"+":::"+targetdb
             pageQueries.push(newLoadedStatement) //TODO


             paginatorHandler.send(pageQueries)

             Logger.log.debug(pageQueries.first)
             result = connection.sql(Regex.fromStr(":::").split(pageQueries.first)[0]).prepare.query
           }

           (result as List).each |row|
           {
             tableVals.push(SqlRow(row))
           }
           //Reveal to watchers that you are ready
           colVals.getAndSet(tableVals.first.cols.toImmutable)
           rowVals.getAndSet(tableVals.toImmutable)
           querVal.getAndSet(thedata[2].toImmutable)
           watcherCols.set()
           watcherRows.set()
           newQuery.set()

           Desktop.callAsync |->|
           {
             updateTable(tableVals)
           }
         }
         else
         {
           Desktop.callAsync |->| {
             updateStatus(emptyresp,null,startTime)
             }
           return result
         }
     case queryUnseen:
         Log.get("pbpsql").info("Worker ${this.hash} querying ${server.host}")
         result = connection.sql(statement).prepare.query
         //TODO: Pagination support here
         if((result as List).size >0)
         {
           tableVals := SqlRow[,]
           (result as List).each |row|
           {
             tableVals.push(SqlRow(row))
           }
          Desktop.callAsync |->|
           {
             updateTable(tableVals)
           }
         }
         else
         {
           Desktop.callAsync |->| {
             updateStatus(emptyresp,null,startTime)
             }
           return result
         }
     default:
   }
   connection.close
   }
   catch(SqlErr e)
   {
    Log.get("pbpsql").err("Sql Err",e)
     Desktop.callAsync |->| { updateStatus(sqlerr,e) }
     return result
   }
   catch(IOErr e)
   {
      Log.get("pbpsql").err("Connection Err",e)
     Desktop.callAsync |->| { updateStatus(ioerr,e) }
     return result
   }
   catch(Err e)
   {
      Log.get("pbpsql").err("Err", e)
     Desktop.callAsync |->| { updateStatus(oerr,e) }
     return result
   }

   Desktop.callAsync |->| { updateStatus(liveconn,null,startTime) }
   return result
 }


Void updateStatus(Str command, Err? err := null, Duration? startTime := null)
  {
    label := Actor.locals[handleStatus] as Label
    if (label != null)
    {
      switch(command)
      {
      case ping:
        label.text = "Status: pinging..."
      case query:
        label.text = "Status: querying..."
      case queryUnseen:
        label.text = "Status: querying..."
      case execute:
        label.text = "Status: executing..."
      case idle:
        label.text = "Status: idle"
      case ioerr:
        label.text = "Status: connection failed..."+err.msg
      case sqlerr:
        label.text = "Status: SQL Error - "+err.msg
      case oerr:
        label.text = "Status: Error - "+err.msg
      case liveconn:
        label.text = "Status: OK Last Update - ${DateTime.now}  ${(Duration.now-startTime).toMillis}ms"
      case emptyresp:
        label.text = "Status: OK Last Update - ${DateTime.now}  ${(Duration.now-startTime).toMillis}ms  EMPTY TABLE"
      }
    }
  }

Void updateTable(SqlRow[] rows)
{
  table := Actor.locals[handleTable] as Table
  if (table != null)
  {
    (table.model as SqlTableModel).update(rows)
    table.refreshAll
  }
}

}

const class SqlDatabaseWalker : Actor
{
  new make() : super(ActorPool())
  {
  }

  **
  ** Walks the database, assumes user has permissions...
  **
  override Obj? receive(Obj? msg)
  {
    SqlDatabase target_db := (msg as List).get(0)
    SqlTable[] cap_tables := [,]
    SqlConn sqlConn := SqlUtil.getDatabaseConn(target_db)

    try
    {

    sqlConn.sql("use ${target_db.name};").execute
    sqlConn.meta.tables.each |table, index|
    {
      SqlCol[] cols := [,]
      cap_tables.push(SqlTable{ name = table; children = [,]; parent = target_db})

      Row row := sqlConn.meta.tableRow(table)
      row.cols.each |col|
      {
        cols.push(SqlCol{name=col.name; parent=cap_tables.peek})
      }
        cap_tables[index] = SqlTable{ name = cap_tables[index].name; children = cols; parent = target_db}
      }


      SqlDatabase fullDb := SqlDatabase{name = target_db.name; children = cap_tables; parent = target_db.parent}


      return fullDb
      }
      catch(Err e)
      {
        return e
      }
      finally
      {
        sqlConn.close
      }
  }

}
