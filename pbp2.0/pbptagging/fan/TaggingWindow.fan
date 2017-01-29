/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using projectBuilder
using pbpgui
using pbpcore
using concurrent

class TaggingWindow : PbpWindow
{
    private static const Key ctrlSpace := Key.ctrl + Key.space

    private ProjectBuilder projectBuilder

    private TaggingEditor taggingEditor

    private Text textBox
    private Text textCount
    private Table table

    private ActorPool actorPool
    private LoadActor loadActor

    private Str? currentFilter

    private TableFilter tableFilter

    private Int textBoxSelectStart := -1
    private Int textBoxSelectSize := -1

    private |->| refreshRecordsFunc

    private Bool suggestInFile := false

    private Key suggestKey

    private Str? oldFilterText := null

    new make(ProjectBuilder projectBuilder, TaggingEditor taggingEditor, |->| refreshRecordsFunc) : super(projectBuilder.builder)
    {
        this.mode = WindowMode.windowModal

        this.projectBuilder = projectBuilder
        this.taggingEditor = taggingEditor
        this.refreshRecordsFunc = refreshRecordsFunc

        this.actorPool = ActorPool()
        this.loadActor = createLoadActor(actorPool)

        this.size = Size(800, 600)
        this.title = "Tagging"

        this.suggestKey = createSuggestKey

        this.onClose.add |event| { actorPool.kill }

        this.textCount = Text() { it.text = "..." }
        this.textCount.enabled = false

        this.textBox = Text()
        this.textBox.onKeyDown.add |event| { textBoxOnKeyDown(event) }
        this.textBox.onKeyUp.add |event| { textBoxOnKeyUp(event) }
        this.textBox.onFocus.add |event| { textBoxOnFocus(event) }
        this.textBox.onBlur.add |event| { textBoxOnBlur(event) }
        this.table = Table()
        this.table.model = TaggingTableModel([,])
        this.table.onFocus.add |event| { textBox.focus }
        this.tableFilter = TableFilter(table, textCount)

        this.content = InsetPane()
        {
            it.content = EdgePane()
            {
                it.top = InsetPane(0, 0, 12, 0)
                {
                    it.content = EdgePane()
                    {
                        it.center = textBox
                        it.right = ConstraintPane() { it.maxw = 200; it.maxw = 200; it.content = textCount }
                        it.bottom = Label() { it.text = taggingEditor.infoText }
                    }
                }
                it.center = table
            }
        }

        relayout

        loadActor.send(null)
    }

    // modified from fwt::Command.makeLocale
    private static Key createSuggestKey()
    {
        pod := TaggingWindow#.pod
        platform := Desktop.platform
        keyBase := "suggestCommand"

        acceleratorStr := pod.locale("${keyBase}.accelerator.${platform}", null)
        acceleratorStrForPlatform := (acceleratorStr != null)

        acceleratorStr = acceleratorStr ?: pod.locale("${keyBase}.accelerator", null)

        accelerator := ctrlSpace
        try
        {
            if (acceleratorStr != null)
            {
                accelerator = Key.fromStr(acceleratorStr)

                // if on a Mac and an explicit .mac prop was not defined, then automatically swizzle Ctrl to Command
                if (!acceleratorStrForPlatform && Desktop.isMac)
                {
                    accelerator = accelerator.replace(Key.ctrl, Key.command)
                }
            }
        }
        catch
        {
            accelerator = ctrlSpace
            Command#.pod.log.err("Suggest command: cannot load '${keyBase}.accelerator ' => $acceleratorStr (default ${ctrlSpace} was used)")
        }

        return accelerator
    }

    private LoadActor createLoadActor(ActorPool actorPool)
    {
        return LoadActor(actorPool) |TaggingRow[] loadedRows| { tryUpdateTable(loadedRows) }
    }

    private Void tryUpdateTable(TaggingRow[] loadedRows)
    {
        table.model = TaggingTableModel(loadedRows)
        tableFilter.refreshModel()
        table.refreshAll
        filterTableRows(true)

        try
        {
            table.selected = (loadedRows.isEmpty ? [,] : [0])
        }
        catch(Err e)
        {
            // WTF
        }
    }

    private Void textBoxOnKeyDown(Event event)
    {
        switch (event.key)
        {
            case Key.up:
                moveTableSelectedRow(table, true)
                event.consumed = true
            case Key.down:
                moveTableSelectedRow(table, false)
                event.consumed = true
            case suggestKey:
                if (oldFilterText == null)
                {
                    textBoxOnBlur
                    textBoxSelectSize = 0
                    oldFilterText = textBox.text
                }
        }
    }

    private static Void moveTableSelectedRow(Table table, Bool up)
    {
        if (table.selected.first == null) { return }

        Int selected := table.selected.first
        size := table.model.numRows
        newSelected := -1

        if (up)
        {
            if (selected > 0)
            {
                newSelected = selected - 1
            }
        }
        else
        {
            if (selected < size - 1)
            {
                newSelected = selected + 1
            }
        }

        if (newSelected != -1)
        {
            try
            {
                table.selected = [newSelected]
            }
            catch (Err e)
            {
                // WTF
            }
        }
    }

    private Void textBoxOnKeyUp(Event event)
    {
        switch (event.key)
        {
            case Key.keypadEnter:
            case Key.enter:
                event.consumed = true
                applyTagsAndCloseWindow(event.window)
                return
            case suggestKey:
                event.consumed = true
                toggleSuggestInFile

                textBox.text = oldFilterText
                oldFilterText = null
                textBoxOnFocus

                return
            case Key.backspace:
            case Key.delete:
                if (textBox.text == "") { suggestInFile = false }
        }

        filterTableRows

        if (table.selected.isEmpty)
        {
            try
            {
                table.selected = (table.model.numRows == 0 ? [,] : [0])
            }
            catch (Err e)
            {
                // WTF
            }
        }
    }

    private Void filterTableRows(Bool force := false)
    {
        if (textBox.text == currentFilter && !force) { return } // no change in filter text

        currentFilter = textBox.text

        tableFilter.filter(suggestInFile, currentFilter)
    }

    private Void textBoxOnFocus(Event? event := null)
    {
        if (textBoxSelectStart != -1 && textBoxSelectSize != -1)
        {
            textBox.select(textBoxSelectStart, textBoxSelectSize)
        }
    }

    private Void textBoxOnBlur(Event? event := null)
    {
        textBoxSelectStart = textBox.selectStart
        textBoxSelectSize = textBox.selectSize
    }

    private Void applyTagsAndCloseWindow(Window window)
    {
        if (table.selected.isEmpty) { return }

        selectedTaggingRow := (table.model as TaggingTableModel ?: throw Err("Invalid table.model $table.model")).getRow(table.selected.first)
        taggingEditor.applyTags(selectedTaggingRow)

        refreshRecordsFunc()

        window.close
    }

    private Void toggleSuggestInFile()
    {
        suggestInFile = !suggestInFile
        filterTableRows(true)
    }

}
