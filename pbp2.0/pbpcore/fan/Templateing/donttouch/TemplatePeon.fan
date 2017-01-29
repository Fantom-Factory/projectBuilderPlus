/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using pbplogging

const class TemplatePeon : Actor
{
  const static Str CONVERT := "CONVERT"
  const static Str REPLICATE := "REPLICATE"
  const static Str FILEWRITER := "FILEWRITER"
  const static Str TREEMAKER := "TREEMAKER"
  const static Str LAYERSEARCHER := "LAYERSEARCHER"
  const Str currentConfig

  const Map? options

  new make(Str config, Map? options, ActorPool pool := TemplateEngine.peonPool) : super(pool)
  {
    currentConfig = config
    this.options = options
  }

  override Obj? receive(Obj? msg)
  {
    switch(currentConfig)
    {
      case CONVERT:
        return convertFileToRec(msg)
      case REPLICATE:
      try
      {
        TemplateTreeNode node := msg
        TemplateLayer layer := node.layer
        //Replicate,
         Record newRec := replicateRecord(node)
         newoptions := [:]
        //Check if root or not...
        if(options.containsKey("root") == false)
        {
          newoptions = ["parentRec":newRec].addAll(options)
        }
        else
        {
          Record parentRec := options["parentRec"]
          //Take parentRef...
          Tag parentTag := TagFactory.setVal(layer.parentref, parentRec.id)
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
        //send to filewriter,
        //This needs to be coordinated in another actor.
        //options["dbcoor"]->send(newRec)
        options["dbthread"]->send([DatabaseThread.SAVE,newRec])
        // replicate children (send new parent ref via TemplateTreeNode -> layer -> parentRef)
        node.children.each |child|
        {
          if(newoptions.containsKey("root") == false)
            {
              newoptions.add("root",false)
            }
          TemplatePeon(TemplatePeon.REPLICATE, newoptions, pool).send(child)//WhenDone(dbwrite,child)
        }
        }
        catch(Err e)
        {
          Logger.log.err("Error", e)
        }
        return null
      case TREEMAKER:
        return updateTree(msg)
      case LAYERSEARCHER:
        return searchLayer(msg, options["TreeMaker"])
      default:
        return null
    }
  }

  Future searchLayer(TemplateLayer layer, Actor treeMaker)
  {
    WatchType watchType := layer.rules.find |Watch w->Bool|{return w.typeof==WatchType#}
    Type type := watchType.typetowatch
    Record[] dirToSearch := Project(options["project"], false).database.getClassMap(type).vals
    dirToSearch.each |file|
    {
      Future future := TemplatePeon(CONVERT, options).send(file)
      treeMaker.send(future)
    }
    while(treeMaker.pool.isDone){}
    return treeMaker.send(null)
  }

  Record convertFileToRec(File file)
  {
    return Record.fromFile(file)
  }

  TemplateTree updateTree(Record rec)
  {
    Str treeid := options["TemplateTreeId"]
    if(Actor.locals[treeid] == null)
    {
      TemplateTree tree := options["TemplateTree"]
      Actor.locals[treeid] = AtomicRef(tree.toImmutable)
    }
    TemplateTree templateTree := Actor.locals[treeid]->val
    templateTree.insert(rec)
    Actor.locals[treeid]->getAndSet(templateTree.toImmutable)
    return templateTree
  }


  Record replicateRecord(TemplateTreeNode node)
  {
    Record record := RecordFactory.replicateFromTemplateRec(node.record, node.record.id.toStr)
    return record

  }


}



