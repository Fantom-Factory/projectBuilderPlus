/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpgui
using pbpcore
using concurrent
using fwt
using gfx


class SqlPackageEditPane : EdgePane
{
  Str name
  AtomicRef listRef
  ActorPool newPool
  Instruction pbpIdInstruction
  Instruction parentRefInstruction
  Instruction tagsToMapInstruction
  Instruction additionalTagInstruction
  Instruction[] instructions
  Actor[] updateableActors := [,]
  Watcher[] watches := [,]

  InstructionBox instructionBox
  SqlColSelector pbpidselector
  SqlColSelector? parentpbpidselector
  Button parentMapSqlColButton := Button{mode=ButtonMode.radio; text="This Column will have the pbpid to look up:"}
  Button parentMapLaterButton := Button{mode=ButtonMode.radio; text="Map Later"}
  ButtonGrid buttonGrid := ButtonGrid{}
  SqlFormThingyBlob[] blobs := [,]
  GridPane pbpIdGridPane := GridPane{numCols=2}
  GridPane tagsToMapGridPane := GridPane{numCols=4}
  GridPane regExRuleGridPane := GridPane{numCols=5}
  GridPane strMatRuleGridPane := GridPane{numCols=2}
  Tag? parentRef
  Str:Obj? options

  new make(Str dis, Tag? parentRefed, Tag[] tagsToMap, AtomicRef listRef, Str:Obj? options)
  {
    this.parentRef = parentRefed
    this.listRef = listRef
    newPool = ActorPool()
    name = dis
    this.options = options
    pbpIdInstruction = Instruction(
      "Select Col for Unique Identification",
      "pbpId"
    )
    pbpIdGridPane.add(Label{text="Sql Col: "})
    pbpidselector = SqlColSelector(listRef)
    updateableActors.push(SqlColSelectUpdater(pbpidselector, getWatcher(), newPool))
    updateableActors.peek.send(null)
    pbpIdGridPane.add(pbpidselector)
    pbpIdInstruction.addField(pbpIdGridPane)
    parentRefInstruction = Instruction(
      "Parent Reference",
      "parentRef"
    )
    if(parentRef!=null){
      parentRefInstruction.addField(parentMapSqlColButton)

      parentpbpidselector = SqlColSelector(listRef)
      updateableActors.push(SqlColSelectUpdater(parentpbpidselector, getWatcher(), newPool))
      updateableActors.peek.send(null)

      parentRefInstruction.addField(parentpbpidselector)
      parentRefInstruction.addField(parentMapLaterButton)
      parentRefInstruction.addField(Label{font=Font{bold=true}; text="Tag to map parenRef to:"})
      parentRefInstruction.addField(InstructionSmartBox(parentRef))
      }

    tagsToMapInstruction = Instruction(
      "Tag Mapping",
      "tagMapper"
    )

    Label tagNameLabel := Label{text="Tag Name"}
    Label colLabel := Label{text="Sql Column to Map"}
    //TODO Label defValLabel := Label{text="Default Value"}
    Label regLabel := Label{text="Regular Expression"}
    tagsToMapGridPane.add(Label{text=""})
    tagsToMapGridPane.add(tagNameLabel)
    tagsToMapGridPane.add(colLabel)
    //TODO tagsToMapGridPane.add(defValLabel)
    tagsToMapGridPane.add(regLabel)

    tagsToMap.each |tag|
    {
    /*
     SqlColSelector newselector := SqlColSelector(listRef)
     updateableActors.push(SqlColSelectUpdater(newselector, getWatcher(), newPool))
     updateableActors.peek->send(null)
     Label tagLabel := Label{text=tag.name+"<${tag->kind}>"}
     Text defValText := Text{}
     Text regText := Text{}
     tagsToMapGridPane.add(tagLabel)
     tagsToMapGridPane.add(newselector)
     tagsToMapGridPane.add(defValText)

     tagsToMapGridPane.add(regText)
     */
     SqlTagMapper mapper := SqlTagMapper(tag,listRef)
     blobs.push(mapper)
     tagsToMapGridPane.addAll(mapper.getForm)
     updateableActors.push(SqlColSelectUpdater(mapper.colSelector, getWatcher(), newPool))
     updateableActors.peek.send(null)

    }
    tagsToMapInstruction.addField(tagsToMapGridPane)

    additionalTagInstruction = Instruction(
      "Additional Tags",
      "addTags"
    )

    additionalTagInstruction.addField(Button(AddRegexRuleCommand(this)))
    //additionalTagInstruction.addField(Button(AddStrMatchRuleCommand(this)))
    regExRuleGridPane.add(Label{text=""})
    regExRuleGridPane.add(Label{text="Sql Column to Map"})
    regExRuleGridPane.add(Label{text="Regular Expression"})
    regExRuleGridPane.add(Label{text="Tags to add"})
    regExRuleGridPane.add(Label{text=""})
    //strMatRuleGridPane.add(Label{text="Sql Column to Map"})
    //strMatRuleGridPane.add(Label{text="String Matcher"})
    additionalTagInstruction.addField(regExRuleGridPane)
    //additionalTagInstruction.addField(strMatRuleGridPane)
    instructions = [pbpIdInstruction, parentRefInstruction, tagsToMapInstruction, additionalTagInstruction]

    instructionBox = InstructionBox(dis, instructions, true)
    center = instructionBox
    bottom = buttonGrid
  }

  Void addButton(Button button)
  {
    buttonGrid.numCols++
    buttonGrid.add(button)
  }
/*
  Void addTagMapper(Tag tag)
  {
    SqlTagMapper tagMapper := SqlTagMapper(tag, listRef)
    updateableActors.push(SqlColSelectUpdater(tagMapper.sqlColSelector, getWatcher(), newPool))
    updateableActors.peek->send(null)
    tagsToMapInstruction.addField(tagMapper)
    //tagsToMapInstruction.addField(Text{text=tag.name})
    return
  }
*/
  Void notifyChange()
  {
    watches.each |watch|
    {
      watch.set()
    }
    return
  }

  Watcher getWatcher()
  {
    watches.push(Watcher())
    return watches.peek()
  }


}
