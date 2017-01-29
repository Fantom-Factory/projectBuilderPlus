/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpi
using pbpcore
using concurrent

class SmartBox : Pane
{
  Tag tag
  Button deleteButton := Button{
    text="Delete"
  }

  Button priorityButton := Button{
    onAction.add |e|
    {
      TagService? tagServ := Service.find(TagService#)
      if(tagServ!=null)
      {
        if (!tagServ.containsKey(tag.name))
        {
          tagServ.addTagPriority(tag)
          (e.widget as Button).image = PBPIcons.starSelected
        }
        else
        {
          tagServ.removeTagPriority(tag)
          (e.widget as Button).image = PBPIcons.starUnselected
        }
      }
    }
  }

  Project? selectedProject
  InfoListerButton? findUnitsButton
  InfoListerButton? findKindsButton
  InfoListerButton? findTZButton
  InfoListerButton? findEquipsButton

  SmartBorder border
  //Editable editableField
  Widget field
  
  new make(Tag tag, Project? selectedProject := null)
  {
    this.tag = tag
    TagService? tagServ := Service.find(TagService#)
    if(tagServ != null)
    {
      if (tagServ.containsKey(tag.name)) {
        priorityButton.image = PBPIcons.starSelected
      } else {
        priorityButton.image = PBPIcons.starUnselected
      }
    }
    border = SmartBorder(tag)
    field = GuiUtil.getEditable(tag)
    add(field)
    add(priorityButton)
    add(deleteButton)
      
    if (tag.name == "unit") {
      findUnitsButton = InfoListerButton{
        text="Find Units"
        rowList=Unit.list.map |u| { u.definition }.sort
        updateField=field
        actionUpdater=|Str defn -> Str| {
          Unit.list.find |Unit u -> Bool| { return u.definition == defn}.name
        }
      }
      add(findUnitsButton)
    }
    if (tag.name == "kind") {
      findKindsButton = InfoListerButton{
        text="Find Kinds"
        rowList=["Bin", "Bool", "Date", "DateTime", "Marker", "Number",
                 "Ref", "Remove", "Str", "Time", "Uri", "Coord"].sort
        updateField=field
      }
      add(findKindsButton)
    }
    if (tag.name == "tz") {
      findTZButton = InfoListerButton{
        text="Find TimeZones"
        rowList=TimeZone.listNames.map |tz| { tz }.sort
        updateField=field
      }
      add(findTZButton)
    }
    if (tag.name == "equipRef" || tag.name == "siteRef") {
      Type? classMapType
      Str? classMapTitle
      if (tag.name == "equipRef") {
        classMapType = Equip#
        classMapTitle = "Find Equips"
      } else {
        classMapType = Site#
        classMapTitle = "Find Sites"
      }
      if (selectedProject != null) {
        typeList := selectedProject.database.getClassMap(classMapType)
        findEquipsButton = InfoListerButton{
          text=classMapTitle
          rowList=typeList.vals.map |Record typeRec -> Str| {
            return typeRec.get("dis").val.toStr
          }
          updateField=field
          actionUpdater=|Str selectedRef -> Str| {
            Record selectedRec := typeList.find |Record val, key| {
              val.get("dis").val == selectedRef
            }
            return selectedRec.id.toStr
          }
        }
        add(findEquipsButton)
      }
    }
    add(border)
  }

  Tag getTag()
  {
    if(field.typeof.fits(EditField#))
    {
      return (field as EditField).getTagFromField
    }
    else{
      return tag
    }
  }

  Void addWatcher(AtomicBool saveStatus, Watcher watcher)
  {
    AtomicBool modfiySaveHack := AtomicBool(false)
    if(field.typeof.method("onModify",false)!=null)
    {
      field->onModify->add |e|
      {
        if(modfiySaveHack.getAndSet(true))
        {
          watcher.set
          saveStatus.getAndSet(false)
        }
      }
    }
    if(field.typeof.method("onAction",false)!=null)
    {
      field->onAction->add |e|
      {
        watcher.set
        saveStatus.getAndSet(false)
      }
    }
  }

  override Size prefSize(Hints hints := Hints.defVal) { return Size(550, 70) }

  override Void onLayout()
  {
    border.pos = gfx::Point.defVal
    border.size = border.prefSize

    priorityButton.pos = gfx::Point(20,35)
    priorityButton.size = priorityButton.prefSize

    deleteButton.pos = gfx::Point(70,35)
    deleteButton.size = deleteButton.prefSize

    field.pos = gfx::Point(140,38)
    field.size = field.prefSize

    [findUnitsButton, findKindsButton, findTZButton, findEquipsButton].each |button| {
      if (button != null) {
        button.pos = gfx::Point(410, 34)
        button.size = button.prefSize
      }
    }
  }
}

class SmartBorder : Canvas
{
  Tag tag
  
  new make(Tag tag)
  {
    this.tag = tag
  }
  const Color markerColor := Color("#c2e1ff")
  const Color recidColor := Color("#fdf6b5")
  const Color strColor := Color("#bbfdb5")
  const Color numColor := Color("#a5dea5")
  const Color dateTimeColor := Color("#75C7F0")
  const Color tagColor := Color("#F7CDDB")
  override Size prefSize(Hints hints := Hints.defVal) { return Size(550, 70) }

  override Void onPaint(Graphics g)
  {
    w := size.w
    h := size.h
    g.antialias = true
    //g.brush = Desktop.sysBg
    switch(tag.typeof)
      {
        case MarkerTag#:
          g.brush = markerColor
        case RefTag#:
          g.brush = recidColor
        case StrTag#:
          g.brush = strColor
        case NumTag#:
          g.brush = numColor
        case DateTimeTag#:
          g.brush = dateTimeColor
        default:
          g.brush = tagColor
      }
    g.fillRect(0, 0, w, h)
    g.brush = Color.black
    g.font = Font.fromStr("12pt Arial")
    g.drawText("${tag.name} - ${tag->kind}",20,4)
    labelWidth := g.font.width("${tag.name} - ${tag->kind}")
    newStartx := labelWidth+27

    switch(tag.typeof)
    {
      case MarkerTag#:
        g.brush = markerColor
      case RefTag#:
        g.brush = recidColor
      case StrTag#:
        g.brush = strColor
      case NumTag#:
        g.brush = numColor
      case DateTimeTag#:
        g.brush = dateTimeColor
      default:
        g.brush = tagColor
    }

    //g.brush = Color("#E3E6E8")
    g.drawLine(7,14,14,14)
    g.drawLine(newStartx,14,490,14)
    g.drawLine(490,14,490,68)
    g.drawLine(490,68,7,68)
    g.drawLine(7,68,7,14)
  }
}
