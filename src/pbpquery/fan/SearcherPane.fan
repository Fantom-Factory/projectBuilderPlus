/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using projectBuilder
using pbpcore
using pbpgui

class SearcherPane : EdgePane, RecordSpace
{
    private Table table
    private Text text
    private Button clearButton
    private Searcher searcher
    private ToolBar toolbar

    new make (Searcher searcher) : super() {
        this.searcher = searcher

        table = Table()
        {
          it.model = RecTableModel([:], searcher.pbp.currentProject)
          it.multi = true
          it.onAction.add |e|
          {
            doSelect(e)
          }
          it.onPopup.add |e|
          {
            e.popup = createPopup
          }
          it.onKeyDown.add |e| {
            if (e.key == Key.esc) {
              table.selected = [,]
            }
            if (e.key == (Key.ctrl + Key.a) || e.key == (Key.command + Key.a)) {
              table.selected = [,]
              rowIdx := [,]
              (table.model as RecTableModel).rows.each |row, idx| {
                rowIdx.push(idx)
              }
              table.selected = rowIdx
            }
          }
        }

        text = Text()
        {
          it.text = "*:*"
          it.onKeyDown.add |Event e|
          {
            if (e.key == Key.up)
            text.text = searcher.up(text.text)
            else if(e.key == Key.down)
            text.text = searcher.down(text.text)
          }
          it.onAction.add |e|
          {
            newQuery((e.widget as Text).text)
          }
        }
        
        clearButton = Button()
        {
          it.text = "Clear"
          it.onAction.add |e|
          {
            text.text = "*:*"
          }
        }

        toolbar = ToolBar()
        toolbar.addCommand(ClearSelectionCommand(this))
        toolbar.addCommand(EditRecordCommand(searcher.pbp, this))
        toolbar.addCommand(DeleteRecordCommand(searcher.pbp, this))
        toolbar.addCommand(InsertRecordCommand(searcher.pbp, this))

        ToolbarExt.initToolbarExts(["queryToolbar": QueryToolbarCommandAdder(this)], [searcher.pbp, this])


        this.top = toolbar
        this.center = table
        this.bottom = EdgePane()
        {
            it.left = clearButton
            it.center = text
        }
    }

    Void newQuery(Str text)
    {
        Time start := Time.now

        this.text.text = text
        try
        {
            update()
        }
        catch
        {
            Dialog.openErr(window, "Invalid query.")
        }

        refreshAll()
        echo(Time.now.toDuration - start.toDuration)
    }

    Void addFilter(Str filter, Bool isNot := false)
    {
        Str not := isNot ? " NOT " : ""
        if (this.text.text.size > 0)
        {
            newQuery("("+this.text.text + ") AND${not}( " + filter + " )")
        }
        else
        {
            newQuery("${not}( " + filter + " )")
        }
    }

    override Record[] getSelectedPoints()
    {
        return (table.model as RecTableModel).getRows(table.selected)
    }

    Void doSelect(Event e)
    {
        table := e.widget as Table
        if (table == null) return

        records := getSelectedPoints
        echo(records)
        prj := searcher.pbp.currentProject
        if (records.size >= 2)
        {
            MultiRecordEditor(prj, records, e.window).open
        }
        else if (records.size == 1)
        {
            RecordEditor(prj,records[0], e.window).open
        }

        update()
        refreshAll
    }

    Void update()
    {
        (table.model as RecTableModel).update(searcher.query(text.text))
    }

    Void refreshAll()
    {
        table.refreshAll()
    }

    private Menu createPopup()
    {
        return Menu()
        {
            MenuItem()
            {
                it.text = "Refresh";
                it.onAction.add |e|
                {
                    reloadQuery()
                }
            },
        }
    }

    Void reloadQuery()
    {
        newQuery(this.text.text)
    }

    Void clearSelection()
    {
        table.selected = [,]
    }

    Void addToolbarCommand(Command command)
    {
        toolbar.addCommand(command)
    }
}
