/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using util
using xml
using fwt

class ConvertCsvToTag
{
Void main()
{
  Window dummy := Window(null)
  {
    content = Button{
    text= "test"
    onAction.add |e|
    {
      File csvfile := FileDialog().open(e.window)
      InStream csvIn := csvfile.in
      CsvInStream csvstream := CsvInStream(csvIn)
      XElem root := XElem("taglib"){XAttr("version","2.0"),}
      csvstream.eachRow |row|
      {
        root.add(XElem(row[0]){XAttr("val",""), XAttr("kind", row[1]),})
      }
      XDoc newdoc := XDoc(root)
      File taglibsave := FileDialog{mode=FileDialogMode.saveFile}.open(e.window)
      OutStream taglibsaveout := taglibsave.out
      newdoc.write(taglibsaveout)
      taglibsaveout.close
      csvIn.close
    }
    }
  }
  dummy.open()
  }
}
