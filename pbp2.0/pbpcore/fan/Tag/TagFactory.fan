/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using haystack
using xml

class TagFactory
{

  static Tag getTag(Str name, Obj? val)
  {
    switch(val.typeof)
    {
      case Bin#:
        return BinTag{it.name=name; it.val=val?:Bin("text/plain")}
      case Bool#:
        return BoolTag{it.name=name; it.val=val?:true}
      case Date#:
        return DateTag{it.name=name; it.val=val?:Date.today()}
      case DateTime#:
        return DateTimeTag{it.name=name; it.val=val?:DateTime.now()}
      case Marker#:
        return MarkerTag{it.name=name; it.val=val?:Marker.fromStr(name)}
      case Num#:
      case Float#:
      case Int#:
        return NumTag{it.name=name; it.val=val.toImmutable} //TODO: Number()
      case Ref#:
        return RefTag{it.name=name; it.val=val?:Ref.gen()}
      case Str#:
        return StrTag{it.name=name; it.val=val?:""}
      case Time#:
        return TimeTag{it.name=name; it.val=val?:Time.now()}
      case Uri#:
        return UriTag{it.name=name; it.val=val?:``}
      default:
        return StrTag{it.name=name; it.val=val.toStr}
    }
  }

  static Tag setVal(Tag tag, Obj? val)
  {
    switch(tag.typeof)
    {
      case BinTag#:
        return BinTag{it.name=tag.name; it.val=val }
      case BoolTag#:
        return BoolTag{it.name=tag.name; it.val=val }
      case DateTag#:
        return DateTag{it.name=tag.name; it.val=val }
      case DateTimeTag#:
        return DateTimeTag{it.name=tag.name; it.val=val }
      case MarkerTag#:
        //Don't do anything to marker tags...
        return MarkerTag{it.name=tag.name; it.val=tag.val }
      case NumTag#:
        return NumTag{it.name=tag.name; it.val=val }
      case RefTag#:
        return RefTag{it.name=tag.name; it.val=val }
      case StrTag#:
        return StrTag{it.name=tag.name; it.val=val }
      case TimeTag#:
        return TimeTag{it.name=tag.name; it.val=val }
      case UriTag#:
        return UriTag{it.name=tag.name; it.val=val }
      default:
        return Tag{it.name=tag.name; it.val=val }
    }
  }

  static Tag setValFromStr(Tag tag, Obj? val)
  {
    switch(tag.typeof)
    {
      case BinTag#:
        return BinTag{it.name=tag.name; it.val=val }
      case BoolTag#:
        return BoolTag{it.name=tag.name; it.val=val}
      case DateTag#:
        return DateTag{it.name=tag.name; it.val=val }
      case DateTimeTag#:
        return DateTimeTag{it.name=tag.name; it.val=val }
      case MarkerTag#:
        //Don't do anything to marker tags...
        return MarkerTag{it.name=tag.name; it.val=tag.val }
      case NumTag#:
        return NumTag{it.name=tag.name; it.val=val }
      case RefTag#:
        return RefTag{it.name=tag.name; it.val=val }
      case StrTag#:
        return StrTag{it.name=tag.name; it.val=val }
      case TimeTag#:
        return TimeTag{it.name=tag.name; it.val=val }
      case UriTag#:
        return UriTag{it.name=tag.name; it.val=val }
      default:
        return Tag{it.name=tag.name; it.val=val }
    }
  }

  static Tag getBlankVal(Tag tag)
  {
    switch(tag.typeof)
    {
      case BinTag#:
        return BinTag{it.name=tag.name; it.val=null }
      case BoolTag#:
        return BoolTag{it.name=tag.name; it.val=null}
      case DateTag#:
        return DateTag{it.name=tag.name; it.val=null }
      case DateTimeTag#:
        return DateTimeTag{it.name=tag.name; it.val=null }
      case MarkerTag#:
        //Don't do anything to marker tags...
        return MarkerTag{it.name=tag.name; it.val=tag.val }
      case NumTag#:
        return NumTag{it.name=tag.name; it.val=null }
      case RefTag#:
        return RefTag{it.name=tag.name; it.val=null}
      case StrTag#:
        return StrTag{it.name=tag.name; it.val=null}
      case TimeTag#:
        return TimeTag{it.name=tag.name; it.val=null}
      case UriTag#:
        return UriTag{it.name=tag.name; it.val=null}
      default:
        return Tag{it.name=tag.name; it.val=null}
    }
  }

  static Tag rename(Tag tag, Str newname)
  {
    switch(tag.typeof)
    {
      case BinTag#:
        return BinTag{it.name=newname; it.val=tag.val }
      case BoolTag#:
        return BoolTag{it.name=newname; it.val=tag.val }
      case DateTag#:
        return DateTag{it.name=newname; it.val=tag.val }
      case DateTimeTag#:
        return DateTimeTag{it.name=newname; it.val=tag.val }
      case MarkerTag#:
        return MarkerTag{it.name=newname; it.val=tag.val }
      case NumTag#:
        return NumTag{it.name=newname; it.val=tag.val }
      case RefTag#:
        return RefTag{it.name=newname; it.val=tag.val }
      case StrTag#:
        return StrTag{it.name=newname; it.val=tag.val }
      case TimeTag#:
        return TimeTag{it.name=newname; it.val=tag.val }
      case UriTag#:
        return UriTag{it.name=newname; it.val=tag.val }
      default:
        return Tag{it.name=newname; it.val=tag.val }
    }
  }


  static Tag fromKindStr(Str name, Str kind)
  {

    switch(kind){
      case "Bin":
       return BinTag{it.name=name}
      case "Bool":
       return BoolTag{it.name=name}
      case "Date":
       return DateTag{it.name=name}
      case "DateTime":
       return DateTimeTag{it.name=name}
      case "Marker":
       return MarkerTag{it.name=name}
      case "Num":
       return NumTag{it.name=name}
      case "Ref":
       return RefTag{it.name=name}
      case "Str":
       return StrTag{it.name=name}
      case "Time":
       return TimeTag{it.name=name}
      case "Uri":
       return UriTag{it.name=name}
      default:
       return Tag{it.name=name}
      }
  }


//TODO: need to fix this to properly place vals... ugh
    static Tag getTagFromXml(XElem target)
      {
      Str name  := target.name
      Str? val := target.attr("val").val.toStr
      Str kind := target.attr("kind").val.toStr
      switch(kind)
      {
        case "Bin":
          return BinTag{it.name=name; it.val=val?:Bin("text/plain")} //TODO: Needs some work, since I've never actually had to use this yet to begin with...
        case "Bool":
          return BoolTag{it.name=name; it.val=val?:Bool.fromStr(val)}
        case "Date":
          return DateTag{it.name=name; it.val=val?:Date.fromStr(val)}
        case "DateTime":
          return DateTimeTag{it.name=name; it.val=val?:DateTime.fromStr(val)}
        case "Marker":
          return MarkerTag{it.name=name; it.val=val?:Marker.fromStr(name)}
        case "Number":
          return NumTag{it.name=name; it.val=val?:Number(val.toStr)}
        case "Num":
          return NumTag{it.name=name; it.val=val?:Number(val.toStr)}
        case "Int":
          return NumTag{it.name=name; it.val=val?:Number(val.toStr)}
        case "Ref":
          return RefTag{it.name=name; it.val=Ref.fromStr(val)}
        case "Ref":
          return RefTag{it.name=name; it.val=Ref.fromStr(val)}
        case "Str":
          return StrTag{it.name=name; it.val=val}
        case "Time":
          return TimeTag{it.name=name; it.val=val?:Time.fromStr(val)}
        case "Uri":
          return UriTag{it.name=name; it.val=val?:val.toUri}
        default:
          return StrTag{it.name=name; it.val=val?:val}
      }

      }

}
