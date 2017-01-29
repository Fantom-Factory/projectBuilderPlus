/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using [java] org.projecthaystack.io::HZincWriter
using [java] org.projecthaystack::HVal

/**
 * @author 
 * @version $Revision:$
 */

class TreePane : EdgePane
{
    private Tree tree
    private Window parentWindow
    private ProgressBar progressBar
    private Label titleLabel
    private Button addButton
    private Button addSitesButton
    private Button annotatedOnly

    private |NavNode[]| onAddToProjectFunc
    private |NavNode[]| onAddSitesToProjectFunc
    private |NavNode| onLoadNodeFunc
    private NavNode[] roots

    Str title { set { &title = it; titleLabel.text = &title } }
    Int? selectedConnectionIdx

    new make(Window parentWindow, NavNode[] roots, |NavNode[]| onAddToProjectFunc, |NavNode[]| onAddSitesToProjectFunc, |NavNode| onLoadNodeFunc)
    {
        this.parentWindow = parentWindow
        this.onAddToProjectFunc = onAddToProjectFunc
        this.onAddSitesToProjectFunc = onAddSitesToProjectFunc
        this.onLoadNodeFunc = onLoadNodeFunc
        this.roots = roots

        this.tree = Tree()
        {
            it.model = NavNodeTreeModel(this.roots)
            it.onPopup.add |Event e| { onPopup(e) }
            it.onAction.add |Event e| { onAction(e) }
            it.multi = true
        }

        this.titleLabel = Label()
        this.title = "..."

        this.progressBar = ProgressBar() { it.indeterminate = true }

        this.addButton = Button.makeCommand(Command.makeLocale(Pod.of(this), "cmdAddToProject", |Event event| { onAddToProject(event) }))
        this.addSitesButton = Button.makeCommand(Command.makeLocale(Pod.of(this), "cmdAddSitesToProject", |Event event| { onAddSitesToProjectFunc(roots) }))
        this.annotatedOnly = Button(){ it.text = "axAnnotated only"; mode = ButtonMode.check}

        this.top = EdgePane() { it.top = titleLabel; it.bottom = addSitesButton }
        this.center = tree
        this.right = addButton
        this.bottom = annotatedOnly
        // this.bottom keep empty/null (place for progressbar)
    }

    Void showProgress()
    {
        this.tree.enabled = false
        this.addButton.enabled = false
        this.addSitesButton.enabled = false
        try { this.bottom.remove(annotatedOnly) } catch { /* show/hide too fast in SWT queue */ }
        this.bottom = progressBar
        relayout
    }

    Void hideProgress()
    {
        this.tree.enabled = true
        this.addButton.enabled = true
        this.addSitesButton.enabled = true
        try { this.bottom.remove(progressBar) } catch { /* show/hide too fast in SWT queue */ }
        this.bottom = annotatedOnly
        relayout
    }


    Void refrechRoots()
    {
        tree.model = NavNodeTreeModel(roots)
        tree.refreshAll
    }

    Void onAddToProject(Event event)
    {
        sel := tree.selected
        if (sel.isEmpty) { return }

        selNodes := sel.findAll |item -> Bool| { item is NavNode && (item as NavNode)->point != null } as NavNode[] ?: throw Err()
        if (!selNodes.isEmpty)
        {
            onAddToProjectFunc(selNodes)
        }
    }

    Void onAction(Event event)
    {
        doActionOnNavNode(event) |NavNode node|
        {
            if (node.navId != null && node.children.isEmpty) { onLoadNodeFunc(node) }
        }
    }

    Void onPopup(Event event)
    {
        doActionOnNavNode(event) |NavNode node|
        {
            event.popup = Menu()
            {
                MenuItem()
                {
                    it.text = "Show info"
                    it.onAction.add |e|
                    {
                        NavNodeInfoDialog(parentWindow, node).open
                    }
                },
            }

            if (node.navId != null && node.children.isEmpty)
            {
                event.popup.add(MenuItem()
                {
                    it.text = "Load children for '${node.dis}'"
                    it.onAction.add |e|
                    {
                        onLoadNodeFunc(node)
                    }
                })
            }
        }
    }

    private static Void doActionOnNavNode(Event event, |NavNode| actionFunc)
    {
        if (event.data isnot NavNode) { return }

        node := event.data as NavNode

        isSite := node?->site != null
        isEquip := node?->equip != null
        isPoint := node?->point != null

        if (isSite || isEquip || isPoint)
        {
            actionFunc(node)
        }
    }

    Void selectNodeByNavId(NavNode navNode)
    {
        if (navNode.navId == null) { return }

        n := findNavNodeByNavId(roots, navNode.navId)
        if (n == null) { return }

        Desktop.callAsync |->| { tree.select(n) }
    }

    Void expandNavPathByNavId(NavNode[] navPath)
    {
        navPath.each |n|
        {
            treeNode := findNavNodeByNavId(roots, n.navId)
            if (treeNode != null)
            {
                Desktop.callAsync |->| { tree.setExpanded(treeNode, true) }
            }
        }
    }

    private static NavNode? findNavNodeByNavId(NavNode[] roots, HVal navId)
    {
        return roots.eachWhile |n|
        {
            if (n.navId == navId) return n
            return findNavNodeByNavId(n.children, navId)
        }
    }


    Bool fetchAxAnnotatedOnly()
    {
        return annotatedOnly.selected
    }
}
