/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore

class TreeUtil
{

static RecordTree interpretTree(Wizard wiz)
  {
    RecordTreeRule[] rules := [,]
    wiz.boxes.each |box| //each one of these is a layer
    {
      Watch[] watches := [,]
      Tag? parentRef := null
      box.instructions.each |instruct|
      {
        if(instruct.id != null)
        {
          switch(instruct.id)
          {
            case WatchId.have:
              watches.push(WatchTags{tagstowatch=PbpUtil.getTagsFromInstruct(instruct);})
            case WatchId.haveVal:
              watches.push(WatchTagVals{tagstowatch=PbpUtil.getTagsFromInstruct(instruct);})
            case WatchId.haveNot:
              watches.push(WatchTagsExclude{tagstowatch=PbpUtil.getTagsFromInstruct(instruct);})
            case WatchId.parentRef:
              parentRef=PbpUtil.getTagsFromInstruct(instruct).first
            case WatchId.isType:
              watches.push(WatchType{typetowatch=PbpUtil.getTypeFromInstruct(instruct)})
          }
        }
      }
      rules.push(RecordTreeRule{it.name = box.disText.text; it.rules=watches; it.parentref=parentRef;})
    }
    return RecordTree{treename=wiz.nameText.text; it.rules = rules}
  }


}
