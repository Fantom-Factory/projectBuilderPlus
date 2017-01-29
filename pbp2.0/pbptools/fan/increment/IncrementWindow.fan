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

class IncrementWindow : PbpWindow
{
    private Str id
    private ProjectBuilder projectBuilder
    private Record[] records
    private GridPane numIncrementPane
    private Table tagTable
    private Text textStart
    private Text textStep
    private |->| afterUpdateFunc

    new make(Str id, ProjectBuilder projectBuilder, Record[] records, |->| afterUpdateFunc) : super(projectBuilder.builder)
    {
        this.id = id
        this.projectBuilder = projectBuilder
        this.records = records
        this.afterUpdateFunc = afterUpdateFunc

        this.mode = WindowMode.windowModal
        this.size = Size(640, 480)

        this.textStart = Text() { it.text = "1"; it.onBlur.add(createTextWithIntOnBlurFunc()) }
        this.textStep = Text() { it.text = "1"; it.onBlur.add(createTextWithIntOnBlurFunc()) }

        this.numIncrementPane = createNumIncrementPane()
        this.tagTable = createTable()

        this.content = EdgePane()
        {
            it.center = InsetPane(12, 12, 0, 12) { it.content = SashPane()
            {
                    it.orientation = Orientation.vertical
                    tagTable,
                    InsetPane() { it.content = numIncrementPane },
            } }
            it.bottom = InsetPane() { it.content = EdgePane()
            {
                it.right = GridPane()
                {
                    it.numCols = 2
                    Button()
                    {
                        it.text = "Increment values"
                        it.onAction.add |Event e|
                        {
                            tags := selectedTags(tagTable)

                            if (tags.isEmpty)
                            {
                                Dialog.openInfo(window, "No tags selected! Please select tag to modify.")
                            }
                            else
                            {
                                doIncrementValues(tags)
                            }
                        }
                    },
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

        numIncrementPane.enabled = false

        relayout
    }

    private Table createTable()
    {
        return Table()
        {
            it.model = pbptools::TagTableModel(getTagsFromRecords(records))
            it.onSelect.add |event|
            {
                numIncrementPane.enabled = !tagTable.selected.isEmpty
            }
        }
    }

    private GridPane createNumIncrementPane()
    {
        return GridPane()
        {
            it.numCols = 2
            Label() { it.text = "Start" },
            textStart,
            Label() { it.text = "Step" },
            textStep,
        }
    }

    private Void doIncrementValues(Tag[] tags)
    {
        start := textStart.text.toInt(10, false)
        step := textStep.text.toInt(10, false)

        if (start == null || step == null)
        {
            Dialog.openInfo(window, "Input text 'start' ($textStart.text) or 'step' ($textStep.text) is not valid.")
        }
        else
        {
            tagRecords := Record[,]
            nullRecords := Record[,]
            invalidRecords := Record[,]

            i := start
            records.each |record|
            {
                tag := record.get(tags.first.name)

                if (tag is NumTag)
                {
                    tagRecords.add(record)
                    FileUtil.createRecFile(projectBuilder.prj, record.set(tag.setVal(i)))
                    i += step
                }
                else
                if (tag == null)
                {
                    nullRecords.add(record)
                    FileUtil.createRecFile(projectBuilder.prj, record.set(NumTag() { it.name = tags.first.name; it.val = i}))
                    i += step
                }
                else
                {
                    invalidRecords.add(record)
                }
            }

            msgTagRecords := "$tagRecords.size records has been modified."
            msgNullRecords := "$nullRecords.size records has new created tag."
            msgInvalidRecords := "$invalidRecords.size records are invalid (they have tag '${tags.first.name}' with unsupported data type)."

            detailNullRecords := "Records with new tag:\n" + nullRecords.join("\n") |record -> Str| { record.id.toStr }
            detailInvalidRecords := "Invalid records:\n" + invalidRecords.join("\n") |record -> Str| { record.id.toStr }
            details := "$detailNullRecords\n\n$detailInvalidRecords"

            afterUpdateFunc()

            Dialog.openInfo(window, "$records.size records have been processed.\n\n$msgTagRecords\n$msgNullRecords\n$msgInvalidRecords", details)

            close
        }
    }

    private static Tag[] selectedTags(Table tagTable)
    {
        model := tagTable.model as pbptools::TagTableModel ?: throw Err("Table model is not of type ${pbptools::TagTableModel#}")

        return model.getTags(tagTable.selected)
    }

    private static |Event e| createTextWithIntOnBlurFunc()
    {
        return |Event e|
        {
            textWidget := e.widget as Text ?: throw Err("Only Text is supported")
            num := textWidget.text.toInt(10, false)
            if (num == null) textWidget.text = "1"
        }
    }

    private static Tag[] getTagsFromRecords(Record[] records)
    {
        Tag:Tag set := records.reduce(Tag:Tag[:]) |Tag:Tag reduction, Record item -> Tag:Tag|
        {
            return reduction.setList(item.data)
        }

        return set.vals.findAll |Tag item -> Bool| { item is NumTag }
    }
}
