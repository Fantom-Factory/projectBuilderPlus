/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

class Build : build::BuildPod
{
  new make()
  {
    podName = "pbpcore"
    summary = "Core data-types for projectBuilder plus"
    version = Version([1,2,1])
    depends = ["sys 1.0+",
               "concurrent 1.0+",
               "haystack 1.9",
               "util 1.0+",
               "web 1.0+",
               "xml 1.0+",
               "fwt 1.0+",
               "pbplogging 1.0+",
               ]

    //javaDirs = [`java/Indexer/`]
    srcDirs = [`fan/`,
               `fan/Actor/`,
               `fan/Actor/configs/`,
               `fan/Change/`,
               `fan/Database/`,
               `fan/Database/config/`,
               `fan/Diagnostics/`,
               `fan/Project/`,
               `fan/Record/`,
               `fan/Record/configs/`,
               `fan/Misc/`,
               `fan/Indexer/`,
               `fan/Templateing/`,
               `fan/Templateing/donttouch/`,
               `fan/Templateing/donttouch/TemplateVisitors/`,
               `fan/Templateing/config/`,
               `fan/File/`,
               `fan/Conn/`,
               `fan/Tree/`,
               `fan/Tag/`,
               `test/`
               ]

  }

}

