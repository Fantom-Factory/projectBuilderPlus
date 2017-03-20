/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore

class TagEditorTest : Test
{
  Void testTagEditor()
  {
    TagLib taglib := TagLib{
      tagLibFile = FileUtil.getTagDir+`standard.taglib`
    }
    TagEditor(null,taglib).open

  }

}
