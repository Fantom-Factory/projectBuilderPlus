/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore

**
** Define a map in a file
**
@Serializable
const class FileMap
{ 
  const Uuid id := Uuid()

  ** Display name of this pair
  const Uri fileUri
  
  ** Display name of this pair
  const Str dis
    
  ** Index for timestamp column
  const Int tsIndex
  
  ** Index for value column
  const Int valIndex
  
  ** Name/header for timestamp column, if exists  
  const Str tsName
  
  ** Name/header for value column, if exists  
  const Str valName
  
  ** Index for value column
  const Int? discriminatorIndex
  
  ** Name/header for timestamp column, if exists  
  const Str? discriminatorName
  
  ** Name/header for value column, if exists  
  const Str? discriminatorVal
  
  Bool hasDiscriminator()
  {
    return (discriminatorIndex != null)
  }

  **
  ** Linked point ID
  **
  const Obj? pointRef := null

  **
  ** Linked point name
  **
  const Str? pointDis := null

  **
  ** Constructor
  **
  new makeParam(Uri fileUri, Str dis, Int tsIndex, Int valIndex, Str tsName := "", Str valName := "", 
              Int? discriminatorIndex := null, Str discriminatorName := "", Str discriminatorVal := "")
  {    
    this.fileUri = fileUri
    this.dis = dis
    this.tsIndex = tsIndex
    this.valIndex = valIndex
    this.tsName = tsName
    this.valName = valName        
    this.discriminatorIndex = discriminatorIndex
    this.discriminatorName = discriminatorName
    this.discriminatorVal = discriminatorVal
  }

  new make(|This| f) { f(this) }

  new makeCopy(FileMap other, |This|? overwriteFunc := null)
  {
    this.id = other.id
    this.fileUri = other.fileUri
    this.dis = other.dis
    this.tsIndex = other.tsIndex
    this.valIndex = other.valIndex
    this.tsName = other.tsName
    this.valName = other.valName        
    this.discriminatorIndex = other.discriminatorIndex
    this.discriminatorName = other.discriminatorName
    this.discriminatorVal = other.discriminatorVal
    this.pointRef = other.pointRef
    this.pointDis = other.pointDis

    overwriteFunc?.call(this)
  }

  override Str toStr()
  {
    return "${super.toStr} {
              id=${id}; 
              fileUri=${fileUri}; 
              dis=${dis};
              tsIndex=${tsIndex};
              valIndex=${valIndex};
              tsName=${tsName};
              valName=${valName};
              discriminatorIndex=${discriminatorIndex};
              discriminatorName=${discriminatorName};
              discriminatorVal=${discriminatorVal};
              pointRef=${pointRef}
              pointDis=${pointDis};
            }" 
  }
}
