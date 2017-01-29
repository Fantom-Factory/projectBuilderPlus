/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using xml
using haystack
using pbpcore
using fwt
using gfx
using pbplogging
using projectBuilder
using web::WebClient

class SkysparkConn : Conn
{
  private const Str secret := "dsfudh%^%&RFggds1152321771234gIY*&658&TT*GGIKbbdlcud897ruuoiy"

  override Str dis
  override Str? projectName // not set in constructor, set later by AddConnCommand, and also saved by save() method
  override Str[] prefixes := ["http://"]
  override Str user := ""
  override Str host := ""
  private Str? pass
  public Bool status
  private Client? client
  const Str ext := "skyconn"

  private LicenseInfo licenseInfo

  new make(Str dis, Str host, Str user, Str pass, LicenseInfo licenseInfo)
  {
    this.dis = dis
    this.host = host
    this.user = user
    this.pass = pass
    this.licenseInfo = licenseInfo

    try
    {
      connect
      testConn
    }
    catch(Err err)
    {
      Logger.log.err("Error connecting to Skyspark Database", err)
      Dialog.openErr(Desktop.focus.window,"Error connecting to Skyspark Database",InsetPane{Label{text=err.traceToStr},})
    }
  }

  **
  ** Connect to the skyspark server.
  **
  override Obj? connect()
  {
    client = Client.open(host.toUri, user, pass)
    return this
  }

  ** Check whether allowed to connect according to SAS lciense
  ** will throw exceptions if it fails
  Void checkSas()
  {
    try
    {
        sc := SkysparkClient.open(host.toUri, user, pass)
        sc.validateSas(secret, licenseInfo)
    }
    catch(Err e)
    {
        client = null
        throw(e)
    }
  }


  **
  ** Test connection.. could throw AuthErr if wrong credentials... or IOErr if no internet etc.
  **
  override Bool testConn()
  {
    try
    {
      if(client != null)
      {
        client.about
      }
      checkSas
    }
    catch(AuthErr err)
    {
      //TODO:: log here.
      Logger.log.err("Test connection error", err)
      Dialog.openErr(null, "$err", err)
      status = false
      return status
    }
    catch(IOErr err)
    {
      //TODO:: log here.
      Logger.log.err("Test connection error", err)
      Dialog.openErr(null, "$err", err)
      status = false
      return status
    }
    status = true
    return status
  }


  Void uploadProjectToConn()
  {
    File? pbpfile := FileUtil.getProjectHomeDir(projectName).listFiles.find|File f->Bool|{return f.ext == "pbp"}
    if(pbpfile != null)
    {
      //1 copy contents of zip to historical data for later use (sync)
      File tempDir := FileUtil.getConnDir(projectName).createDir("${host.toUri.host}temp")
      tempDir.deleteOnExit
      pbpin := pbpfile.in

      zipRead := Zip.read(pbpin)
      File? entry
      Str:File files := [:]
      while((entry = zipRead.readNext()) != null)
      {
        File newfile := tempDir.createFile(entry.basename)
        OutStream newfileout := newfile.out
        entry.in.pipe(newfileout)
        newfileout.close
        files.add(entry.uri.toStr, newfile)
      }
      zipRead.close
      pbpin.close

      pbpout := pbpfile.out
      zipWrite := Zip.write(pbpout)
      files.each |v,k|
      {
        if(k.toUri != `/uploadhist/${host.toUri.host}/last.upload` && k.toUri!= `/uploadhist/${host.toUri.host}/last.db`)
        {
          OutStream newout := zipWrite.writeNext(k.toUri)
          v.in.pipe(newout)
          newout.close
        }
      }
      histuploadout := zipWrite.writeNext(`/uploadhist/${host.toUri.host}/last.upload`)
      files["/project.upload"].in.pipe(histuploadout)
      histuploadout.close
      histdbout := zipWrite.writeNext(`/uploadhist/${host.toUri.host}/last.db`)
      files["/current.db"].in.pipe(histdbout)
      histdbout.close
      zipWrite.close
      pbpout.close

      Grid grid := ZincReader(files["/project.upload"].in).readGrid

      //Check license for rec limit. if(grid.size >

      if( ! licenseInfo.checkLicenseLimit(grid.size))
      {
        return
      }


      try
      {
        Map results := commitRecs(grid)
        ConstraintPane resultPane := ConstraintPane{
          maxh = 128
          maxw = 435
          content = ResultTable(results)
        }
        Dialog.openInfo(Desktop.focus.window, "Commiting Records Completed",resultPane)
        Str:Str passwordFile := (FileUtil.getProjectHomeDir(projectName)+`pw.p`).readObj
        passwordFile.each |pass, key|
        {
          plain := Crypto().decode(pass,"NOTsoSecretgrapeFruit#2334")
          Logger.log.debug(plain.toStr)
          result:=client.eval(""" passwordSet("${key}", "${plain}") """)
          if(result.isErr)
          {
            Str trace := result.meta["errTrace"].toStr
            Logger.log.err("Recent Error Trace: ${trace}", null)
            Logger.log.debug(result.meta["err"])
          }
          Logger.log.debug(key)
        }
      }
      finally {
        addRecsToProject()
      }
    }
  }

  Void syncConn(Bool useDisMacro := false) {
    File? pbpfile := FileUtil.getProjectHomeDir(projectName).listFiles.find|File f->Bool|{return f.ext == "pbp"}

    if (pbpfile!=null) {
      //1 copy contents of zip to historical data for later use (sync)
      File tempDir := FileUtil.getConnDir(projectName).createDir("${host.toUri.host}temp")
      tempDir.deleteOnExit
      pbpin := pbpfile.in
      
      zipRead := Zip.read(pbpin)
      File? entry
      Str:File files := [:]
      while((entry = zipRead.readNext()) != null)
      {
        File newfile := tempDir.createFile(entry.basename)
        OutStream newfileout := newfile.out
        entry.in.pipe(newfileout)
        newfileout.close
        files.add(entry.uri.toStr, newfile)
      }
      zipRead.close
      pbpin.close
      
      if (!files.containsKey("/uploadhist/${host.toUri.host}/last.db")) {
        return
      }
      
      Str:Map lastUploadedDb := files["/uploadhist/${host.toUri.host}/last.db"].readObj
      Str:Map currentDb := files["/current.db"].readObj
      Str:Record olderBro := lastUploadedDb["Record"]
      Str:Record youngerBro := currentDb["Record"]
      
      toAdd := Record[,]
      toDelete := Record[,]
      toMod := Change[][,]
      changes := Change[,]

      olderBro.each |Record v, Str k|
      {

        if (!youngerBro.containsKey(k)) {
          toDelete.push(v)
        }
        else if((changes = ChangeUtil.compareRecs(v, youngerBro[k], useDisMacro)).size > 0)
        {
          toMod.push(changes)
        }
      }

      youngerBro.each |Record v, Str k|
      {
        if (!olderBro.containsKey(k))
        {
          toAdd.push(v)
        }
      }

      dicts := Dict[,]
      toAdd.each |Record add| {
        if (useDisMacro && (add.typeof == Equip# || add.typeof == pbpcore::Point#)) {
          add = add.remove("dis")
        }
        dicts.push(add.getDict)
      }

      Grid addGrid := Etc.makeDictsGrid(["commit":"add"], dicts)
      Map results := commitRecs(addGrid)

      //TODO: toDelete gets iterated and we'll add the trashTag to these recs...

      if (toDelete.size > 0) {
        toDelete.each |Record rec|
        {
          Grid result := client.eval("readById(${rec.id}).diff({trash}).commit")
          if(result.isErr)
          {
            Str trace := result.meta["errTrace"].toStr
            Logger.log.err("Recent Error Trace: ${trace}", null)
            Logger.log.err("Error removing rec ${result.meta}", null)
          }
          Str resultStr := "Successful"
          if(result.isErr){resultStr = "Modding Failed"}
          results.add("Deleteing "+rec.id.toStr,["dis":rec.get("dis").val.toStr, "result":resultStr])
        }
      }
      //TODO: toMod-> iterate through each List, each list are all the changes on said rec, combine to make one diff, commit that diff
      if (toMod.size > 0) {
        toMod.each |changeset| {
          Str recid := changeset.first.target.toStr
          Str evalstr := "readById($recid).diff({"
          changeset.each |change, index| {
            if (change.target.toStr == recid && index != changeset.size.minus(1))
            {
              Tag targetTag := change.opts.first
              if(targetTag.typeof == StrTag#)
              {
                evalstr = evalstr + targetTag.name.toStr + ":" + "\"" + targetTag.val.toStr.replace("""\$""", """\\\$""") + "\","
              }
              else
              {
                evalstr = evalstr + targetTag.name.toStr + ":" +  targetTag.val.toStr + ","
              }
            }
            else
            {
              Tag targetTag := change.opts.first
              if(targetTag.typeof == StrTag#)
              {
                evalstr = evalstr + targetTag.name.toStr + ":" + "\"" + targetTag.val.toStr.replace("""\$""", """\\\$""") + "\""
              }
              else if(targetTag.typeof == UriTag#)
              {
                evalstr = evalstr + targetTag.name.toStr + ":" + "`" + targetTag.val.toStr.replace("""\$""", """\\\$""") + "`"
              }
              else
              {
                evalstr = evalstr + targetTag.name.toStr + ":" +  targetTag.val.toStr
              }
            }
          }
          evalstr = evalstr + "}).commit"
          Grid result := client.eval(evalstr)

          if (result.isErr) {
            Str trace := result.meta["errTrace"].toStr
            Logger.log.err("Recent Error Trace: ${trace}", null)
            Logger.log.err("Error modding rec ${result.meta}", null)
          }
          Str resultStr := "Successful"
          if(result.isErr){resultStr = "Modding Failed"}
          results.add("Modifying "+changeset.toStr,["dis":"Modding Records", "result":resultStr])
        }
      }
      ConstraintPane resultPane := ConstraintPane{
        maxh = 128
        maxw = 435
        content = ResultTable(results)
      }
      Dialog.openInfo(Desktop.focus.window, "Syncing Records Completed",resultPane)
      //TODO: toAdd turns into Grid to upload
      Str:Str passwordFile := (FileUtil.getProjectHomeDir(projectName)+`pw.p`).readObj
      passwordFile.each |pass, key|
      {
        plain := Crypto().decode(pass,"NOTsoSecretgrapeFruit#2334")
        
        Grid resultPass := client.eval("""passwordSet(${Ref.fromStr(key)}, "${plain}")""")
        if(resultPass.isErr)
        {
          Str trace := resultPass.meta["errTrace"].toStr
          Logger.log.err("Error setting password ${resultPass.meta}", null)
          Logger.log.err("Recent Error Trace: ${trace}", null)
        }
      }
      
      pbpout := pbpfile.out
      zipWrite := Zip.write(pbpout)
      files.each |v,k|
      {
        if(k.toUri != `/uploadhist/${host.toUri.host}/last.upload` && k.toUri!= `/uploadhist/${host.toUri.host}/last.db`)
        {
          OutStream newout := zipWrite.writeNext(k.toUri)
          v.in.pipe(newout)
          newout.close
        }
      }
      histuploadout := zipWrite.writeNext(`/uploadhist/${host.toUri.host}/last.upload`)
      files["/project.upload"].in.pipe(histuploadout)
      histuploadout.close
      histdbout := zipWrite.writeNext(`/uploadhist/${host.toUri.host}/last.db`)
      files["/current.db"].in.pipe(histdbout)
      histdbout.close
      zipWrite.close
      pbpout.close
    }
  }


  //TODO: could proably beef this up with Task framework...
  **
  ** Commit a group of records to this skyspark connection.
  **
  Map commitRecs(Grid recs)
  {
    Map results := [:]
    Bool errFlag := false
    recs.each |Row r| {
      Grid result := client.commit(Etc.makeDictGrid(["commit":"add"], (Dict)r))
      if(result.isErr)
      {
        Str trace := result.meta["errTrace"].toStr
        Logger.log.err("Recent Error Trace: ${trace}", null)
        Logger.log.debug(result.toStr)
        errFlag = true
      }
      Str resultStr := "Successful"
      if(result.isErr) {resultStr = "Upload Failed"}
      results.add("Adding "+r["id"].toStr, ["dis":r.dis, "result":resultStr])
    }
    return results
  }

  **
  ** Evaluate an expression and return the result.
  **
  Grid eval(Str expr)
  {
    Grid result := client.eval(expr)
    return result
  }

  ** Get the obix connections from skyspark and return the data as a map
  ConnData[] getObixConns()
  {
    ConnData[] conns := [,]
    Grid grid := client.eval("readAll(obixConn)")
    grid.each |row|
    {
      conn := ConnData()
      conn.set("dis", row.dis("dis"))
      conn.set("lobby", row.dis("obixLobby"))
      conn.set("user", row.dis("username"))
      conn.set("id", row.get("id").toStr)
      conns.add(conn)
    }
    return conns
  }

  **
  **  Site, Equips, and Points to project (if they do not already exist)
  **
    override Record[] addRecsToProject()
  {
    if(client == null){return [,]}
    Record[] recs := [,]
    Grid siteGrid := client.eval("readAll(site)")
    Grid equipGrid := client.eval("readAll(equip)")
    Grid pointGrid := client.eval("readAll(point)")
    Grid weatherGrid := client.eval("readAll(weather)")

    siteGrid.each |row|
    {
      Tag[] tags := [,]
      row.each |tagval, tagname|
      {
        if(tagval!=null)
        {
          tags.push(TagFactory.getTag(tagname,tagval))
        }
      }
      normalizeTags(row, tags)
      Ref recid := tags.find|Tag tag->Bool|{return tag.name == "id"}.val
      recs.push(Site{
          id=recid
          data=tags
        })
    }

    equipGrid.each |row|
    {
      Tag[] tags := [,]
      row.each |tagval, tagname|
      {
        if(tagval != null)
        {
            tags.push(TagFactory.getTag(tagname,tagval))
        }
      }
      normalizeTags(row, tags)
      Ref recid := tags.find |Tag tag->Bool|{ return tag.name == "id" }.val
      recs.push(Equip{
          id=recid
          data=tags
        })
    }

    pointGrid.each |row|
    {
      Tag[] tags := [,]
      row.each |tagval, tagname|
      {
        if (tagval != null)
        {
          tags.push(TagFactory.getTag(tagname, tagval))
        }
      }
      normalizeTags(row, tags)
      Ref recid := tags.find|Tag tag->Bool|{return tag.name == "id"}.val
      recs.push(pbpcore::Point{
          id=recid
          data=tags
        })
    }

    weatherGrid.each |row|
    {
      Tag[] tags := [,]
      row.each |tagval, tagname|
      {
        if(tagval!=null)
        {
          tags.push(TagFactory.getTag(tagname,tagval))
        }
      }
      normalizeTags(row, tags)
      Ref recid := tags.find|Tag tag->Bool|{return tag.name == "id"}.val
      recs.push(pbpcore::Weather{
          id=recid
          data=tags
        })
    }
    return recs
  }

  **
  ** Normalize tags of record. Currently add dis tag created using disMacro
  **
  private static Void normalizeTags(Row row, Tag[] tags)
  {
    hasDisTag := tags.find |Tag tag -> Bool| { tag.name == "dis"} != null

    if (hasDisTag) return

    dis := Etc.dictToDis(row)

    tags.add(TagFactory.getTag("dis", dis))
  }

  Void persistLastUpload()
  {
     File? pbpfile := FileUtil.getProjectHomeDir(projectName).listFiles.find|File f->Bool|{return f.ext == "pbp"}
    if(pbpfile != null)
    {
      //1 copy contents of zip to historical data for later use (sync)
      File tempDir := FileUtil.getConnDir(projectName).createDir("${host.toUri.host}temp")
      tempDir.deleteOnExit
      pbpin := pbpfile.in

      zipRead := Zip.read(pbpin)
      File? entry
      Str:File files := [:]
      while((entry = zipRead.readNext()) != null)
      {
        File newfile := tempDir.createFile(entry.basename)
        OutStream newfileout := newfile.out
        entry.in.pipe(newfileout)
        newfileout.close
        files.add(entry.uri.toStr, newfile)
      }
      zipRead.close
      pbpin.close

      pbpout := pbpfile.out
      zipWrite := Zip.write(pbpout)
      files.each |v,k|
      {
        if(k.toUri != `/uploadhist/${host.toUri.host}/last.upload` && k.toUri!= `/uploadhist/${host.toUri.host}/last.db`)
        {
          OutStream newout := zipWrite.writeNext(k.toUri)
          v.in.pipe(newout)
          newout.close
        }
      }
      histuploadout := zipWrite.writeNext(`/uploadhist/${host.toUri.host}/last.upload`)
      files["/project.upload"].in.pipe(histuploadout)
      histuploadout.close
      histdbout := zipWrite.writeNext(`/uploadhist/${host.toUri.host}/last.db`)
      files["/current.db"].in.pipe(histdbout)
      histdbout.close
      zipWrite.close
      pbpout.close

      }

    }

  **
  ** Store a password in the correct place.
  **
  override Void storePass()
  {

  }

  **
  ** Save connection to xml format.
  **
  override XElem toXml()
  {
    XElem rooter := XElem("conn"){XAttr("type","skyspark"),}
    rooter.add(XElem("dis"){XAttr("val",dis),})
    rooter.add(XElem("host"){XAttr("val",host),})
    rooter.add(XElem("user"){XAttr("val",user),})
    rooter.add(XElem("pass"){XAttr("val",Crypto().encode(pass, "waffle#stop%@#rtkke")),}) //TODO: encrypt methods here
    return rooter
  }

  static SkysparkConn? fromXml(File file, LicenseInfo licenseInfo)
  {
    SkysparkConn? conn := null
    InStream filein := file.in
    XElem connElem := XParser(filein).parseDoc.root
    if(connElem.get("type") == "skyspark")
    {
      Str dis := connElem.elems[0].get("val")
      Str host := connElem.elems[1].get("val")
      Str user := connElem.elems[2].get("val")
      Str pass := Crypto().decode(connElem.elems[3].get("val"), "waffle#stop%@#rtkke")
      conn = SkysparkConn(dis,host,user,pass, licenseInfo)
    }
    filein.close
    return conn
  }

  Void save()
  {
    FileUtil.createConnFile(FileUtil.getProjectHomeDir(projectName),this)
  }
}


class ResultTable : Table
{
  Map resultMap
  new make(Map resultMap) : super()
  {
    this.resultMap = resultMap
    this.model = ResultTableModel(resultMap)
  }
}

class ResultTableModel : TableModel
{
  List cols := ["Name", "Result", "Additional Info."]
  Str:Map rows
  new make(Map rows){
    this.rows = rows
    }
  const Int desktopFontSize := Desktop.sysFont.size.toInt
  //TODO: Refactor with Font.width
  override Int? prefWidth(Int col)
  {
    Int startingsize := header(col).size*desktopFontSize
    //Int startingsize := Desktop.sysFont.width(header(col))
    Int prefsize := startingsize
    rows.vals.each |row, index|
    {
      Str field := text(col, index)
      if(field.size* desktopFontSize > prefsize)
      {
        prefsize = field.size*desktopFontSize
      }
    }
    if(prefsize > 120){prefsize=120}
    return prefsize
  }
  override Int numRows(){return rows.size}
  override Int numCols(){return cols.size}
  override Str header(Int col){return cols[col]}
  override Str text(Int col, Int row)
  {
   try{
    switch(col){
      case 0:
        return rows[rows.keys[row]].get("dis").toStr
      case 1:
        return rows[rows.keys[row]].get("result").toStr
      case 2:
        return rows.keys[row].toStr
      default:
        return ""
    }
    }
    catch(Err e)
    {
      return "Err"
    }
  }

}
