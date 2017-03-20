/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using projectBuilder
using pbpcore
using pbpgui
using pbpquery

@MenuExt{ menuId = "tools"; weight = 100 }
class TaggingCommand : Command
{
    private ProjectBuilder projectBuilder

    new make(ProjectBuilder projectBuilder) : super.makeLocale(TaggingCommand#.pod, "taggingCommand")
    {
        this.projectBuilder = projectBuilder
    }

    protected override Void invoked(Event? event)
    {
        try
        {
            if (projectBuilder.currentProject != null)
            {
                selectedRecords := findRecordsOnSelectedTabOrSelectedTree(
                    projectBuilder.builder._recordTabs,
                    projectBuilder.builder._treeTabs)

                if (selectedRecords.isEmpty)
                {
                    Dialog.openErr(projectBuilder.builder, "Unable to find records to tag", "Please select supported tab (Sites, Equips, Points, Query) or tree.")
                }
                else
                {
                    TaggingWindow(projectBuilder,
                        TaggingEditor(projectBuilder, selectedRecords),
                        |->| { refreshRecords() }).open()
                }
            }
            else
            {
                Dialog.openErr(projectBuilder.builder, "Can not start tagging", "Please select project")
            }
        }
        catch (Err e)
        {
            e.trace(Env.cur.out, ["maxDepth": 500])
        }
    }

    private Record[] findRecordsOnSelectedTabOrSelectedTree(TabPane tabPaneRecords, TabPane tabPaneTrees)
    {
        selectedRecords := findRecordsOnSelectedTree(tabPaneTrees) //first search in trees
        if (selectedRecords.isEmpty)
        {
            return findRecordsOnSelectedTab(tabPaneRecords) // than in tables
        }
        else
        {
            return selectedRecords
        }
    }

    private Record[] findRecordsOnSelectedTree(TabPane tabPane)
    {
        if (tabPane.selected == null || Desktop.focus isnot Tree) { return [,] }

        widget := WidgetUtils.findWidgetOfType(tabPane.selected.children, Type[TreeWidget#])
        if (widget is TreeWidget)
        {
            tree := (widget as TreeWidget).tree

            return tree.selected.
                findAll |item -> Bool| { item is RecordTreeNode }.
                map |item -> Record?| { (item as RecordTreeNode).record }
        }
        else
        {
            return [,]
        }
    }

    private Record[] findRecordsOnSelectedTab(TabPane tabPane)
    {
        if (tabPane.selected == null) { return [,] }

        widget := WidgetUtils.findWidgetOfType(tabPane.selected.children, Type[RecordExplorer#, SearcherPane#])
        if (widget is RecordExplorer)
        {
            if (widget === projectBuilder.getSiteToolbar() ||
                widget === projectBuilder.getEquipToolbar() ||
                widget === projectBuilder.getPointToolbar())
            {
                return (widget as RecordExplorer).getSelected
            }
            else
            {
                return [,]
            }
        }
        if (widget is SearcherPane)
        {
            return (widget as SearcherPane).getSelectedPoints
        }
        else
        {
            return [,]
        }
    }

    private Void refreshRecords()
    {

        projectBuilder.builder._recordTabs.tabs.each |tab|
        {
            widget := WidgetUtils.findWidgetOfType(tab.children, Type[RecordExplorer#, SearcherPane#])

            if (widget is RecordExplorer)
            {
                recordExplorer := widget as RecordExplorer

                update := false
                if (widget === projectBuilder.getSiteToolbar())
                {
                    recordExplorer.update(projectBuilder.prj.database.getClassMap(Site#))
                    update = true
                }
                else if (widget === projectBuilder.getEquipToolbar())
                {
                    recordExplorer.update(projectBuilder.prj.database.getClassMap(Equip#))
                    update = true
                }
                else if (widget === projectBuilder.getPointToolbar())
                {
                    recordExplorer.update(projectBuilder.prj.database.getClassMap(pbpcore::Point#))
                    update = true
                }

                if (update) { recordExplorer.refreshAll() }
            }
            else if (widget is SearcherPane)
            {
                searcherPane := widget as SearcherPane
                searcherPane.reloadQuery
            }
        }

        projectBuilder.builder._treeTabs.tabs.each |tab|
        {
            widget := WidgetUtils.findWidgetOfType(tab.children, Type[TreeWidget#])
            if (widget is TreeWidget)
            {
                tree := (widget as TreeWidget).tree

                (tree.model as RecordTreeModel).update()
                tree.refreshAll
            }
        }

    }
}
