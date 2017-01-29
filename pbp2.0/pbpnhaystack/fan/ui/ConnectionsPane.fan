/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt

/**
 * @author 
 * @version $Revision:$
 */
class ConnectionsPane : EdgePane
{
    private ToolBar toolbar
    private Table table
    private ProgressBar progressBar

    private |Event| onAddFunc
    private |Event| onDeleteFunc
    private |Event| onEditFunc
    private |Event| onReconnectFunc
    private |Event| onSyncFunc
    private |Event| onRowSelectedFunc

    private HaystackConnection[] connections

    new make(HaystackConnection[] connections,
        |Event| onAddFunc, |Event| onDeleteFunc, |Event| onEditFunc, |Event| onReconnectFunc, |Event| onSyncFunc,
        |Event| onRowSelectedFunc)
    {
        this.connections = connections

        this.onAddFunc = onAddFunc
        this.onDeleteFunc = onDeleteFunc
        this.onEditFunc = onEditFunc
        this.onReconnectFunc = onReconnectFunc
        this.onSyncFunc = onSyncFunc

        this.onRowSelectedFunc = onRowSelectedFunc

        this.toolbar = ToolBar()

        this.toolbar.addCommand(Command.makeLocale(Pod.of(this), "cmdAdd", |Event event| { this.onAddFunc(event) } ))
        this.toolbar.addCommand(Command.makeLocale(Pod.of(this), "cmdDelete", |Event event| { this.onDeleteFunc(event) } ))
        this.toolbar.addCommand(Command.makeLocale(Pod.of(this), "cmdEdit", |Event event| { this.onEditFunc(event) } ))
        this.toolbar.addCommand(Command.makeLocale(Pod.of(this), "cmdReconnect", |Event event| { this.onReconnectFunc(event) } ))
        this.toolbar.addCommand(Command.makeLocale(Pod.of(this), "cmdSync", |Event event| { this.onSyncFunc(event) } ))

        this.table = Table() { it.model = HaystackConnTableModel(this.connections) }
        this.table.onAction.add |Event e| { this.onRowSelectedFunc(e) }

        this.progressBar = ProgressBar() { it.indeterminate = true }

        this.top = toolbar
        this.center = table
    }

    Void showProgress()
    {
        this.toolbar.enabled = false
        this.table.enabled = false
        this.bottom = progressBar
        relayout
    }

    Void hideProgress()
    {
        this.toolbar.enabled = true
        this.table.enabled = true
        try { this.bottom.remove(progressBar) } catch { /* show/hide too fast in SWT queue */ }
        relayout
    }

    Int? getSelectedConnectionIdx() { return table.selected.first }

    HaystackConnection? getSelectedConnection()
    {
        idx := table.selected.first
        return idx == null ? null : (table.model as HaystackConnTableModel).connection(idx)
    }

    Void refrechConnections()
    {
        table.model = HaystackConnTableModel(connections)
        table.refreshAll
    }

    Void selectConnectionIdx(Int idx)
    {
        table.selected = [idx]
    }

    Void selectConnection(HaystackConnection? conn)
    {
        if (conn == null) { return }
        idx := connections.index(conn)
        if (idx != null)
        {
            selectConnectionIdx(idx)
        }
    }

}
