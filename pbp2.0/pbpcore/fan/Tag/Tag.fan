/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using xml

@Serializable
const class Tag
{
  const Str name
  const Obj? val

  new make(|This| f)
  {
    f(this)
  }

   Tag setVal(Obj? val)
   {
     return  TagFactory.setVal(this,val)
   }
   @Transient
   XElem toXml()
   {
     if(val == null)
     {
      return XElem("${this.name}"){XAttr("val",""), XAttr("kind", this->kind),}
     }
     return XElem("${this.name}"){XAttr("val",this.val.toStr), XAttr("kind", this->kind),}
   }

   @Transient
   static Tag fromXml(XElem elem)
   {
     return TagFactory.getTagFromXml(elem)
   }


   override Str toStr()
   {
     return "${name}:${val.toStr} (${this->kind})"
   }

   override Bool equals(Obj? compare)
   {
     if(compare is Tag && (compare as Tag).name == this.name)
     {
       return true
     }
     else
     {
       return false
     }
   }

   override Int hash() { name.hash }

}
