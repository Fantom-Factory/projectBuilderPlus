/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using haystack
using pbplogging

class TemplateEngine
{
  static const ActorPool managerPool := ActorPool{}
  static const ActorPool workerPool := ActorPool{}
  static const ActorPool peonPool := ActorPool{}
  static const Str templatize := Uuid().toStr
  static const Str deploy := Uuid().toStr
  static const Int recCacheSize := 100

  static Future templatizeTemplate(TemplateType template, Project project, ActorPool pool)
  {
    return TemplateBoss(["extrapolate":template.toImmutable, "TemplateType":template.toImmutable, "project":project.name], pool).send(TemplateEngine.templatize)
  }

  static Future deployTemplate(Uri template, Project project, Map? options := null, ActorPool pool := ActorPool())
  {
    Int iterations := 1
    if(options!= null && options.containsKey("repeat"))
    {
      iterations = iterations.plus(options["repeat"]);
    }
    Int templatesize := File(template).readObj->templateTree->datamash->keys->size
   // MemoryController(ActorPool()).sendLater(1sec, null)
    return TemplateBoss(["repeat":iterations, "Template":template, "dbthread":project.database.getThreadSafe(iterations*templatesize, options["phandler"], pool), "totalsize":iterations*templatesize], pool).send(TemplateEngine.deploy)
  }

  static Void deployX(Template template, Str:Obj options)
  {
    //If iterate, then just plain repeat...
    //If assignment, then go through roots and assign references
    //TODO: 1.1.1, If model, follow csv (other files later?) and build for each one, tagging
    Record[] readyForDeployment := [,]
    readyForDeployment = options["deployscheme"]->templateDeployer->visit(["template":template, "opts": options])
    readyForDeployment.each |newRec|
    {
      options["dbthread"]->send([DatabaseThread.SAVE,newRec])
    }
  }

  static Str:Obj replicateTemplateTree(Template template, Str:Obj? options, Record? record := null)
  {
    Str:Record newRecs := [:]
    TemplateTree tree := template.templateTree
    Str:Str newIdMap := [:]
    Visitor[] visitors := options["visitors"]
    tree.datamash.each |node, recid|
    {
      if(!newIdMap.containsKey(recid))
      {
        newIdMap.add(recid.toStr,Ref.gen().toStr)
      }
      Record toProcess := RecordFactory.replicateFromTemplateRec(node.record, newIdMap[recid.toStr])
      Record? parentRec := null
      Tag? parentRef := node.layer.parentref

      if(!node.layer.root) //non-root
      {
        Str parentId :=  toProcess.get(parentRef.name).val.toStr
        if(!newIdMap.containsKey(parentId))
        {
          newIdMap.add(parentId.toStr,Ref.gen().toStr)
          Logger.log.debug("generating new id")
        }
        parentRec = RecordFactory.replicateFromTemplateRec(tree.datamash[parentId].record, newIdMap[parentId])
      }
      else  //root
      {
        //TODO: ???
      }
      visitors.each |visitor|
      {
        toProcess = visitor.visit(["site":record, "parent":parentRec, "target":toProcess, "layer": node.layer, "newRecMap":newIdMap])
      }
      newRecs.add(toProcess.id.toStr,toProcess)
    }
    return ["newRecs":newRecs, "newIdMap":newIdMap]
   }

}


/*
class TemplateDuplicator
{

  override Obj? receive(Obj? msg)
  {
    Str:Obj? message := msg
    Obj[] visitors := message["visitors"]
    Map toProcess := msg["toProcess"]

    try
    {
      Record? parentRec := toProcess["parent"]
      TemplateTreeNode node := toProcess["target"]
      //Replicate,
      Record newRec := replicateRecord(node) //RecordFactory.replicateFromTemplateRec(node.record)
      newoptions := [:]
      Tag parentTag := TagFactory.setVal(layer.parentref, parentRec.id)
      if(parentRec!=null)
      {
      //Take inheritance...
      newRec = newRec.add(parentTag)
      Tag[] tagstoadd := [,]
      layer.inheritance.each |tag|
      {
        newtag := parentRec.get(tag.name)
        if(newtag!=null){tagstoadd.push(newtag)}
      }
      if(tagstoadd.size > 0)
      {
        newRec = newRec.addAll(tagstoadd)
      }
        newRec = newRec.add(StrTag{name="dis"; val=parentRec.get("dis").val.toStr+"-"+newRec.get("dis").val.toStr})
        newoptions = [:].addAll(options).set("parentRec",newRec)
      }
        //This needs to be coordinated in another actor.
        //options["dbcoor"]->send(newRec)
        //options["dbthread"]->send([DatabaseThread.SAVE,newRec])
        // replicate children (send new parent ref via TemplateTreeNode -> layer -> parentRef)
      node.children.each |child|
      {
        //TemplatePeon(TemplatePeon.REPLICATE, newoptions, pool).send(child)//WhenDone(dbwrite,child)
        sendLater(15ms, )
      }
      }
      catch(Err e)
      {
        Logger.log.err("error", e)
      }
      return null
    }
}
*/



