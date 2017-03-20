/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using haystack
/*
Note: Key Difference is that "id" tag is not included in this.
*/
@Serializable
const class TemplateRecord : Record
{
    const Type baseType
    new make(|This| f) : super(f)
    {
      f(this)
    }
    /*
    @Transient
    override Tag get(Str name)
    {
      data.find |Tag t->Bool| {return t.name == name}
    }
    */

    @Transient
    static TemplateRecord fromRecord(Record rec)
    {
      Tag[] data := [,]
      data.addAll(rec.data.findAll |Tag t->Bool|{return t.name!="id"})
      return TemplateRecord{
        id=rec.id
        it.data = data
        baseType = rec.typeof
      }
    }
}
