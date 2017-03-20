/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


using haystack
using xml

**
** ExportPodTags
** Create taglibs for each pods that has tags
** Taglibs go in [curFolder]/tags/
** ie: [curFolder]/tags/bacnet.taglib
**
class ExportPodTags
{
  Void main()
  {
    folder := `tags/`.toFile
    podDir := (Env.cur.homeDir + `lib/fan/`)
    echo("Pod dir: $podDir.osPath")
    echo("Extracting tags to $folder.osPath")

    data := trioData(podDir)

    // write the tags XML files
    data.each |tags, pod|
    {
      XElem root := XElem("taglib"){XAttr("version","2.0"),}
      tags.each |tag|
      {
        root.add(XElem(tag.name){XAttr("val",""), XAttr("kind", tag.kind), /*XAttr("doc", tag.doc)*/})
      }
      XDoc newdoc := XDoc(root)
      file := folder + `${pod}.taglib`
      echo("$file.osPath")
      out := file.out
      newdoc.write(out)
      out.close
    }
  }

    ** TrioInfo keyed by pod name
  Str:TagInfo[] trioData(File dir)
  {
    Str:TagInfo[] tags := [:]

    dir.listFiles.findAll{it.ext=="pod"}.each |pod|
    {
      TagInfo[] podTags := [,]
      pn := pod.basename
      Zip.open(pod).contents.findAll{ext=="trio"}.each |file|
      {
        TrioReader(file.in).eachRec |dict|
        {
          if(dict.has("tag"))
          {
            podTags.add(TagInfo(pn, toStrMap(dict)))
          }
        }
      }
      if(! podTags.isEmpty)
        tags[pn] = podTags
    }

    return tags
  }

  Str:Str toStrMap(Dict dict)
  {
    Str:Str map:= [:]
    dict.each|obj, str|
    {
      map[str] = obj == null ? null : obj.toStr
    }
    return map
  }
}

const class TagInfo
{
  const Str:Str data
  const Str pod

  new make(Str pod, Str:Str data) {this.data = data; this.pod = pod}

  Str name() {(data["name"] ?: data["tag"]) ?: ""}
  Str doc() {data["doc"] ?: ""}
  Str kind() {data["kind"] ?: ""}

  override Int compare(Obj that)
  {
    if(! (that is TagInfo)) throw Err("Can't compare $typeof with $that.typeof")
    return name <=> (that as TagInfo).name
  }
}

