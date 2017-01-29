/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore
using fwt
using gfx

class GuiUtil
{
  //TODO: Work on adding unique editable fields here ...
  static Widget getEditable(Tag obj)
  {
    Obj? placeholder := obj.val
    if(placeholder == null){
      placeholder = ""
    }
    switch(obj.typeof)
    {
      case BinTag#:
      return Text{text=placeholder.toStr}
      case BoolTag#:
      return Combo{items=[true,false]; selected = placeholder.toStr}
      case DateTag#:
      return Text{text=placeholder.toStr}
      case DateTimeTag#:
      return Text{text=placeholder.toStr}
      case MarkerTag#:
      return MarkerField(obj)
      case NumTag#:
      return NumField(obj)
      case RefTag#:
      return RefField(obj)
      case StrTag#:
      return StrField(obj)
      case TimeTag#:
      return Text{text=placeholder.toStr}
      case UriTag#:
      return UriField(obj)
      default:
      return Text{text=placeholder}
    }
  }

  static Widget? getTargetParent(Widget widget,Type type)
  {
    Widget? currentWidget := widget.parent
    while(currentWidget.typeof != type && currentWidget != null)
    {
      currentWidget = currentWidget.parent
    }
    return currentWidget
  }

  static Pane makeTitle(Str title)
  {
    return InsetPane {
      insets = Insets(0,0,10,0)
      Label {
        text = title
        font = Font { bold = true }
      },
    }
  }
}

internal class EditableText : Text
{
  new make(|This| f) : super(f){}
  override Size prefSize(Hints hints := Hints.defVal){return Size(298,23)}
}
