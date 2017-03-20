/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using gfx
using fwt
using projectBuilder
using pbpgui
using pbpcore

class MapWindow : PbpWindow
{
    private Str id
    private ProjectBuilder projectBuilder
    private Record[] records
    private Table recordTable
    private |->| afterUpdateFunc
    private Button mapButton

    new make(Str id, ProjectBuilder projectBuilder, Record[] records, |->| afterUpdateFunc) : super(projectBuilder.builder)
    {
        this.id = id
        this.projectBuilder = projectBuilder
        this.records = records
        this.afterUpdateFunc = afterUpdateFunc
        this.title = getTitle

        this.mode = WindowMode.windowModal
        this.size = Size(640, 480)

        this.recordTable = createTable()

        this.mapButton = Button()
        {
            it.text = "Map"
            it.onAction.add |Event e|
            {
                recs := selectedRecords(recordTable)
                doMapRecords(recs)
            }
            it.enabled = false
        }


        this.content = EdgePane()
        {
            it.center = InsetPane(12, 12, 0, 12) { it.content = SashPane()
            {
                    it.orientation = Orientation.vertical
                    recordTable,
            } }
            it.bottom = InsetPane() { it.content = EdgePane()
            {
                it.right = GridPane()
                {
                    it.numCols = 2
                    mapButton,
                    Button()
                    {
                        it.text = "Cancel"
                        it.onAction.add |Event e|
                        {
                            this.close()
                        }
                    },
                }
            } }
        }

        relayout
    }

    private Table createTable()
    {
        return Table()
        {
            it.model = pbptools::RecordTableModel(getRecords())
            it.onSelect.add |event|
            {
                mapButton.enabled = !selectedRecords(recordTable).isEmpty
            }
        }
    }

    private Str getTitle()
    {
        switch (id)
        {
            case "equipToolbar": return "Sites to map"
            case "pointToolbar": return "Equips to map"
        }
         throw Err("Invalid toolbar id $id")
    }



    private Tag getSiteRef(Record rec)
    {
        switch (id)
        {
            case "equipToolbar": return rec.get("id")
            case "pointToolbar": return rec.get("siteRef")
        }
         throw Err("Invalid toolbar id $id")
    }

    private Tag? getEquipRef(Record rec)
    {
        switch (id)
        {
            case "equipToolbar": return null
            case "pointToolbar": return rec.get("id")
        }
         throw Err("Invalid toolbar id $id")
    }

    private Void doMapRecords(Record[] recs)
    {

           // there is be only one record
           targetRecord := recs.first
           siteRef := getSiteRef(targetRecord).val
           equipRef := getEquipRef(targetRecord)?.val

           details := StrBuf()


           records.each |rec|
           {
               details.add("processing record: $rec.toStr\n")
               // map reference to site
               siteRefTag := rec.get("siteRef")
               // check whether tag already exists
               if(siteRefTag != null)
               {
                   details.add("    found siteRef tag: ${siteRefTag.val}. Updating to ${siteRef}.\n")
                   rec = rec.set(siteRefTag.setVal(siteRef))
               }
                  else
               {
                   details.add("    siteRef tag not found. Creating new one with value: ${siteRef}.\n")
                   rec = rec.add(RefTag() { it.name = "siteRef"; it.val = siteRef})
               }

               // map reference to equipment
               if(equipRef != null)
               {
                   equipRefTag := rec.get("equipRef")
                   // check whether tag already exists
                   if(equipRefTag != null)
                   {
                       details.add("    found equipRef tag: ${equipRefTag.val}. Updating to ${equipRef}.\n")
                       rec = rec.set(equipRefTag.setVal(equipRef))
                   }
                      else
                   {
                       details.add("    equipRef tag not found. Creating new one with value: ${equipRef}.\n")
                       rec = rec.add(RefTag() { it.name = "equipRef"; it.val = equipRef})
                   }
               }
               details.add("\n")
               FileUtil.createRecFile(projectBuilder.prj, rec)
           }

            afterUpdateFunc()

            Dialog.openInfo(window, "$records.size records have been processed.\n\n", details.toStr)

            close
    }

    private static Record[] selectedRecords(Table recordTable)
    {
        model := recordTable.model as pbptools::RecordTableModel ?: throw Err("Table model is not of type ${pbptools::RecordTableModel#}")

        return model.getRecords(recordTable.selected)
    }

    private Record[] getRecords()
    {
        Record[] recs := Record[,]
        switch (id)
        {
            case "equipToolbar":
                recs.addAll(projectBuilder.prj.database.getClassMap(Site#).vals)
            case "pointToolbar":
                recs.addAll(projectBuilder.prj.database.getClassMap(Equip#).vals)
            default: throw Err("Invalid toolbar id $id")
        }

        return recs
    }



}
