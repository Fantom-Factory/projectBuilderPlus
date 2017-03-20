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

class Step1SelectSiteEquip : ContentPane
{
    private ProjectBuilder projectBuilder
    private ExportModel exportModel

    private Tree tree

    new make(ProjectBuilder projectBuilder, ExportModel exportModel)
    {
        this.projectBuilder = projectBuilder
        this.exportModel = exportModel
        this.tree = Tree()
        {
            multi = true
            model = SiteEquipTreeModel(projectBuilder)
            onSelect.add |Event event|
            {
                exportModel.sitesAndEquips = tree.selected
                updateConnectionsModel
            }
         }

        this.content = EdgePane()
        {
            top = InsetPane(0, 0, 5, 0) { it.content = Label() { text = "Select sites or equipment to commision" } }
            center = tree
        }

        content.relayout

        Desktop.callAsync |->|
        {
            // expand all root nodes
            tree.model.roots().each |root|
            {
                tree.refreshNode(root)
                tree.setExpanded(root, true)
            }

            // make selection based on export model
            tree.selected = exportModel.sitesAndEquips
        }

    }

    private Void updateConnectionsModel()
    {
//        sitesAndEquips
//            connections
    }



}

class SiteEquipTreeModel : TreeModel
{
    private ProjectBuilder projectBuilder

    new make(ProjectBuilder projectBuilder)
    {
        this.projectBuilder = projectBuilder
    }

    override Obj[] roots()
    {
        return projectBuilder.currentProject.database.getClassMap(Site#).vals
    }

    override Str text(Obj node)
    {
        return (node as Record)?.get("dis")?.val?.toStr ?: ""
    }

    override Image? image(Obj node) { return null }

    override Obj[] children(Obj obj)
    {
        parent := obj as Site
        return parent != null ?
            (projectBuilder.currentProject.database.getClassMap(Equip#).findAll |Equip equip -> Bool| { equip.get("siteRef").val == parent.get("id").val }).vals :
            [,]
    }
}
