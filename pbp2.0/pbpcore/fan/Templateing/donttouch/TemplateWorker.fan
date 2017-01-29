/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using pbplogging

const class TemplateWorker : Actor
{
  const Map? options
  new make(Map? options, ActorPool pool) : super(pool)
  {
    this.options = options
  }

  override Obj? receive(Obj? msg)
  {
    switch(msg)
    {
      case TemplateEngine.templatize:
        TemplateType tType := options["TemplateType"]
        TemplatePeon treeMaker := TemplatePeon(TemplatePeon.TREEMAKER, options)
        newoptions := ["TreeMaker":treeMaker, "TemplateTreeId":Uuid().toStr].addAll(options)
        ActorPool peonPool := TemplateEngine.peonPool
        tType.layers.each |layer|
        {
          TemplatePeon(TemplatePeon.LAYERSEARCHER, newoptions, peonPool).send(layer)
        }
        //check pool status here.. lock
        return Actor.locals[newoptions["TemplateTreeId"]]->val

      case TemplateEngine.deploy:
      try
      {
        Template template := File(options["Template"]).readObj

        ActorPool filePool := ActorPool()
        ActorPeon dbCoor := ActorPeon(filePool)
          {
            config=TemplateDeployConfig()
            it.options=this.options
          }
        Map newoptions := ["dbcoor":dbCoor, "reccacheid":Uuid().toStr].addAll(options)
        options["repeat"]->times |->|
        {
        if(!pool.isStopped)
        {
          template.templateTree.roots.each |root|
          {
            TemplatePeon(TemplatePeon.REPLICATE, newoptions, pool).send(root)
          }
        }
        }
      }
      catch(Err e)
      {
        Logger.log.err("Error", e)
      }
        return null
      default:
      return null
    }
  }
}
