/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////



class FileTest : Test
{
  Void testFileUtil()
  {
    verify(!FileUtil.exists("test2"))
    Project test := Project("test2")
    verify(FileUtil.exists("test2"))
    verify(test.homeDir.exists)
    verify(test.connDir.exists)
  }


 override Void teardown()
 {
   FileUtil.getProjectHomeDir("test2").delete
 }


}
