/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using pbplogging

**
**  Directs template to the highly concurrent environment whos sole purpose is to replicate stuff, aka press the same button over and over and over.
**

const class TemplateBoss : Actor
{
  const Map? options

  new make(Map? options, ActorPool pool) : super(pool)
  {
    this.options = options
  }

  override Obj? receive(Obj? MSG)
  {
    Str command := MSG
    switch(command)
    {
      case TemplateEngine.templatize:
        TemplateWorker(options, pool).send(TemplateEngine.templatize)
        return "CALLSIGNCHARLIEALPHAZEROZERONINER"
      case TemplateEngine.deploy:
        Logger.log.debug(MSG)
        TemplateWorker(options, pool).send(TemplateEngine.deploy)
        return "CALLSIGNCHARLIEALPHAZERZEROHEAVEN"
      default:
        return null
    }
  }

}
