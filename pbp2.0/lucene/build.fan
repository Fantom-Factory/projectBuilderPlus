/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using build

class Build : BuildPod {
  new make() {
    podName = "luceneCore"
    summary = "Lucene Core"
    meta    = ["org.name":     "Apache",
               "org.uri":      "http://apache.org/",
               "proj.name":    "Lucene",
               "license.name": "Apache License Version 2.0"]
    version = Version("3.6.1")
    srcDirs = [`fan/`]
    resDirs = [`lucene-core-3.6.1.jar`]
  }
}
