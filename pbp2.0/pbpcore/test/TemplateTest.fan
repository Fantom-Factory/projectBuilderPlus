/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using haystack


class TemplateTest : Test
{
/*
  Void testTemplateing()
  {
    Templateing template := Template{
      it.name = "testtemplate"
      it.desc = "testtemplate"
      it.tags = [TagFactory.getTag("test1",Marker.fromStr("test")),TagFactory.getTag("test2",123), TagFactory.getTag("test3","abc")]
    }

    Templateing templatePack := TemplatePack{
      it.name = "testtemplatepack"
      it.desc = "testtemplatepack"
      it.templates = [[template]]
    }

    verify(template.typeof == Template#)
    verify(templatePack.typeof == TemplatePack#)
    verify(template.name == "testtemplate")
    verify(template.desc == "testtemplate")
    verify(templatePack.name == "testtemplatepack")
    verify(templatePack.desc == "testtemplatepack")
    verify(template->tags->find |Tag t->Bool| {return t.typeof == MarkerTag#}->val.toStr == "marker")
    verify(template->tags->find |Tag t->Bool| {return t.typeof == NumTag#}->val.toStr == 123.toStr)
    verify(template->tags->find |Tag t->Bool| {return t.typeof == StrTag#}->val == "abc")
    verify(template->tags->find |Tag t->Bool| {return t.typeof == MarkerTag#}->name == "test1")
    verify(template->tags->find |Tag t->Bool| {return t.typeof == NumTag#}->name == "test2")
    verify(template->tags->find |Tag t->Bool| {return t.typeof == StrTag#}->name == "test3")

  }

  Void testTemplate()
  {
    //verifyErr(TemplateFactory.getSiteTemplate(RecordFactory.getEquip, "test", "test"))
   // verifyErr(TemplateFactory.getEquipTemplate(RecordFactory.getSite, "test", "test"))
    //verifyErr(TemplateFactory.getPointTemplate(RecordFactory.getEquip, "test", "test"))

    SiteTemplate stemp := TemplateFactory.getSiteTemplate(RecordFactory.getSite, "test", "test")
    EquipTemplate etemp := TemplateFactory.getEquipTemplate(RecordFactory.getEquip, "test", "test")
    PointTemplate ptemp := TemplateFactory.getPointTemplate(RecordFactory.getPoint, "test", "test")

    verify(stemp.name == "test")
    verify(etemp.name == "test")
    verify(ptemp.name == "test")
    verify(stemp.desc == "test")
    verify(etemp.desc == "test")
    verify(ptemp.desc == "test")

  }
  /*
  Void testTemplatePack()
  {
    SiteTemplatePack



  }
  */
*/


}

