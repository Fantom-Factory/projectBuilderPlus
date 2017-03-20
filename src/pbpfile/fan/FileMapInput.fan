/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

**
** UI for specifying timestamp-value pairs
**
class FileMapInput : GridPane
{
  private Combo cmbTs
  private Combo cmbVal
  private Combo cmbDiscriminator
  private Text txtDis := Text { it.prefCols = 5 }
  private Text txtDiscriminator := Text { it.prefCols = 5 }

  new make(Str[] colNames, Str colTimestamp := "", Bool closable := true) : super()
  {
    numCols = closable ? 12 : 11
    
    add(Label { text = "Timestamp" })
    cmbTs = Combo { items = colNames; selected = colTimestamp }
    add(cmbTs)

    add(Label { text = "  Value" })
    cmbVal = Combo { items = colNames }
    add(cmbVal)

    add(Label { text = "  Discriminator" })
    cmbDiscriminator = Combo { items = colNames.dup.insert(0, "") }
    add(cmbDiscriminator)
    add(Label { text = " = " })
    add(txtDiscriminator)

    add(Label { image = Image(`fan://pbpi/res/img/circleRight16.png`) })

    add(Label { text = "Name" })
    add(txtDis)

    if (closable)
    {
      add(Button { 
        image = Image(`fan://pbpi/res/img/clearAny_16_16_32.png`)
        onAction.add |e| { e.widget = this; onClose.fire(e) }
      })
    }
  }

  once EventListeners onClose() { EventListeners() }

  FileMap? map := null

  Str dis
  {
    get { return txtDis.text }
    set { txtDis.text = it }
  }

  Int tsIndex
  {
    get { return cmbTs.selectedIndex }
    set { cmbTs.selectedIndex = it }
  }

  Str tsName
  {
    get { return cmbTs.selected }
    set { cmbTs.selected = it }
  }

  Int valIndex
  {
    get { return cmbVal.selectedIndex }
    set { cmbVal.selectedIndex = it }
  }

  Str valName
  {
    get { return cmbVal.selected }
    set { cmbVal.selected = it }
  }

  Int discriminatorIndex
  {
    get { return cmbDiscriminator.selectedIndex }
    set { cmbDiscriminator.selectedIndex = it }
  }

  Str discriminatorName
  {
    get { return cmbDiscriminator.selected }
    set { cmbDiscriminator.selected = it }
  }

  Str discriminatorVal
  {
    get { return txtDiscriminator.text }
    set { txtDiscriminator.text = it }
  }

  FileMap getFileMap(Uri fileUri)
  {
    if (map != null)
    {
      noDiscriminator := (this.discriminatorIndex == 0)
      return FileMap.makeCopy(map) {
              it.fileUri = fileUri
              it.dis = this.dis
              it.tsIndex = this.tsIndex
              it.valIndex = this.valIndex
              it.tsName = this.tsName
              it.valName = this.valName
              it.discriminatorIndex = noDiscriminator ? null : this.discriminatorIndex-1
              it.discriminatorName = noDiscriminator ? "" : this.discriminatorName
              it.discriminatorVal = noDiscriminator ? "" :this.discriminatorVal
            }
    }
    else
    {
      if (discriminatorIndex == 0)      
        return FileMap.makeParam(fileUri, dis, tsIndex, valIndex, tsName, valName)
      else
        return FileMap.makeParam(fileUri, dis, tsIndex, valIndex, tsName, valName, 
                    discriminatorIndex-1, discriminatorName, discriminatorVal)
    }
  }

  Void setFileMap(FileMap map)
  {
    this.map = map
    dis = map.dis
    tsIndex = map.tsIndex
    valIndex = map.valIndex
    if (map.discriminatorIndex != null)
    {
      discriminatorIndex = map.discriminatorIndex+1
      discriminatorVal = map.discriminatorVal
    }
    else
    {
      discriminatorIndex = 0
    }
  }
}
