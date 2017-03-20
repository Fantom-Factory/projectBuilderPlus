/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using haystack

class TagTest : Test
{

  Void testTagFactory()
  {

    verify( TagFactory.getTag("test",Bin("test/plain")).typeof == BinTag#)
    verify( TagFactory.getTag("test",true).typeof == BoolTag#)
    verify( TagFactory.getTag("test",Date.today()).typeof == DateTag#)
    verify( TagFactory.getTag("test",DateTime.now()).typeof == DateTimeTag#)
    verify( TagFactory.getTag("test",Marker.fromStr("test")).typeof == MarkerTag#)
    verify( TagFactory.getTag("test",5).typeof == NumTag#)
    verify( TagFactory.getTag("test",Ref.gen()).typeof == RefTag#)
    verify( TagFactory.getTag("test","test").typeof == StrTag#)
    verify( TagFactory.getTag("test",Time.now).typeof == TimeTag#)
    verify( TagFactory.getTag("test",`test`).typeof == UriTag#)
  }

}
