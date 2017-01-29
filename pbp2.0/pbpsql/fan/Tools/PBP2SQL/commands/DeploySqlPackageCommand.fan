/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using haystack
using concurrent
using pbpcore
using pbpgui
using projectBuilder
using pbplogging

class DeploySqlPackageCommand : Command
{
  SqlConnWrapper conn

  private ProjectBuilder pbp

  new make(SqlConnWrapper conn, ProjectBuilder pbp):super.makeLocale(Pod.of(this), "deploySqlPackage")
  {
    this.conn = conn
    this.pbp = pbp
  }

   override Void invoked(Event? e)
   {
      resp := Dialog.openQuestion(e.window,"Would you like to create a new deployment scheme?",null,Dialog.yesNo)
      if(resp == Dialog.yes)
      {
        CreateDeploymentSchemeCommand(conn).invoked(e)
      }
      Dialog.openInfo(e.window, "Select deployment scheme to deploy")
      File schemeFile := FileDialog{filterExts=["*.sqlscheme"]; dir=(Env.cur.homeDir+`resources/sql/`)}.open(e.window)
      SqlPackageDeploymentScheme scheme := schemeFile.readObj
      //Hacky here... port to class later.
      File[] dirs := ProjectSelector(e.window, pbp).open()
      if(dirs.size < 0) {return}
      EdgePane mainWrapper := EdgePane{}
      GridPane centerWrapper := GridPane{}
      resp = Dialog.openMsgBox(Pod.of(this), "sqlDeployInfoDialog", e.window, Label{text="Are you sure you would like to deploy this scheme to ${dirs.size} projects?"},mainWrapper,Dialog.yesNo)
      //Debug
      //
      if(resp == null || resp==Dialog.no)
      {
        return
      }

     Record[] recs_precheck := [,]

     scheme.packages.each |pack|
     {
       Str statement := scheme.formMap[pack.id["name"]]
       SqlRow[] rowVals := conn.queryBlocking(statement)
       rowVals.each |row|
       {
         Record? rec := SqlPackageUtil.getRec(pack, row)
         if(rec!=null)
         {
           recs_precheck.push(rec)
         }
       }
     }

    Project? currentProject := pbp.currentProject
    dirs.each |dir|
    {
      newPool := ActorPool()
      ProgressWindow pwindow := ProgressWindow(e.window, newPool)
      Project? project := null
      if(currentProject!=null && dir.basename==currentProject.name)
      {
        project = currentProject
      }
      else
      {
        project = Project(dir.basename)
      }
      Str:Str currentRecMap := [:]
      if((project.connDir+`sql/manifest.db`).exists)
      {
       currentRecMap = (project.connDir+`sql/manifest.db`).readObj
      }

      Record[] recs_postcheck := [,]
        recs_precheck.each |rec|
        {
            type := ""
            if (rec.get("site") != null)
              type = "site"
            else if (rec.get("equip") != null)
              type = "equip"
            else if (rec.get("point") != null)
              type = "point"

            currentRecMap.set(type + rec.get("pbpid").val, rec.id.toStr)
            recs_postcheck.push(rec)
        }
        recs_postcheck.each |rec,index|
        {
          Tag? pbpparentid := rec.get("pbpparentid")
          if(pbpparentid!=null)
          {
            splitted := Regex.fromStr(":::").split(pbpparentid.val)
            refType  := splitted[0]
            parentId := splitted[1]

            Tag? tag := RefTag{it.name=refType; val=Ref.nullRef}

            parentKey := refType[0..-4] + parentId // Strip "Ref" from refType results in "site"/"point"/"equip"
            if(currentRecMap.containsKey(parentKey))
            {
              Tag newTag := TagFactory.setVal(tag,Ref.fromStr(currentRecMap[parentKey]))
              recs_postcheck[index] = rec.add(newTag)
              Logger.log.debug(newTag.toStr)
              Logger.log.debug(newTag.val.toStr)
            }
          }
          Tag[] recIdTags := [,]
          if(pbpparentid!=null)
          {
            recIdTags = rec.data.findAll |Tag t->Bool|{return (t.typeof == RefTag#) && t.name!="id" && t.name!=pbpparentid.name}
          }
          else
          {
            recIdTags = rec.data.findAll |Tag t->Bool|{return (t.typeof == RefTag# && t.name!="id")}
          }
          recIdTags.each |tag|
          {
            if(currentRecMap.containsKey(tag.val.toStr))
            {
              recs_postcheck[index] = recs_postcheck[index].add(TagFactory.setVal(tag, Ref.fromStr(currentRecMap[tag.val.toStr])))
            }
          }
        }


      (project.connDir+`sql/manifest.db`).create.writeObj(currentRecMap)
      DatabaseThread dbthread := project.database.getThreadSafe(recs_postcheck.size, pwindow.phandler, newPool)

        recs_postcheck.each |rec|
        {
          dbthread.send([DatabaseThread.SAVE,rec])
        }
      pwindow.open()
      newPool.stop()
      newPool.join()
      project.database.unlock()
    }


      if(currentProject!=null)
      {
        PbpWorkspace pbpwrapper := pbp.asWorkspace
        pbpwrapper.siteExplorer.update(currentProject.database.getClassMap(Site#))
        pbpwrapper.equipExplorer.update(currentProject.database.getClassMap(Equip#))
        pbpwrapper.pointExplorer.update(currentProject.database.getClassMap(pbpcore::Point#))
        pbpwrapper.siteExplorer.refreshAll
        pbpwrapper.equipExplorer.refreshAll
        pbpwrapper.pointExplorer.refreshAll
      }

     //Look at currently saved sqlpacks... -- 2 classes... window/class table/model I THINK I ALREADY WROTE THESE
     //Feed queries into packs... -- 1 class, (USE TEST AREA)
     //Confirm
     //Select Projects to deploy to.. -- have this class
     //Database thread -> save recs... -- copy/paste
     //TODO:// save config for service.
   }

}




