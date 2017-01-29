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

@MenuExt{ menuId = "file" }
class ExportWizardCommand : Command
{
    private ProjectBuilder projectBuilder

    new make(ProjectBuilder projectBuilder) : super.makeLocale(ExportWizardCommand#.pod, "exportCommand")
    {
        this.projectBuilder = projectBuilder
    }

    protected override Void invoked(Event? event)
    {
        if (projectBuilder.currentProject != null)
        {
            ExportWizard(projectBuilder).open()
        }
        else
        {
            Dialog.openErr(projectBuilder.builder, "Can not export project", "Please select project before export")
        }
    }
}

class ExportWizard : PbpWindow
{
    private static const Int STEP1 := 1
    private static const Int STEP2 := 2
    private static const Int STEP3 := 3
    private static const Int STEP4 := 4

    private ProjectBuilder projectBuilder
    private EdgePane wizardContent
    private WizardStepsPane wizardStepsPane
    private ExportModel exportModel

    new make(ProjectBuilder projectBuilder) : super(projectBuilder.builder)
    {
        this.mode = WindowMode.windowModal

        this.projectBuilder = projectBuilder

        this.exportModel = ExportModel()

        this.size = Size(800, 600)

        this.wizardStepsPane = WizardStepsPane(
            4,
            |Int currentPage, Int oldPage -> Void| { onPageChange(currentPage, oldPage) },
            |Int currentPage -> Void| { onCancel(currentPage) },
            |Int currentPage -> Void| { onFinish(currentPage) },
            |Int currentPage -> Str| { getPageMessage(currentPage) },
            |Int currentPage, Int newPage -> Bool| { canGotoPage(currentPage, newPage) }
        )

        this.content = wizardContent = EdgePane()
        {
            it.bottom = wizardStepsPane
            it.center = InsetPane(10)
        }

        relayout

        Desktop.callAsync |->|
        {
            wizardStepsPane.gotoPage(STEP1)
        }
    }

    private Void changeWizardContent(ContentPane contentPane)
    {
        (wizardContent.center as InsetPane).content = contentPane
        contentPane.relayout()
        (wizardContent.center as InsetPane).relayout()
    }

    private Void onPageChange(Int currentPage, Int oldPage)
    {
        goingForward := currentPage > oldPage

        switch (currentPage)
        {
            case STEP1:
                changeWizardContent(Step1SelectSiteEquip(projectBuilder, exportModel))
            case STEP2:
                changeWizardContent(Step2Connections(projectBuilder, exportModel))
            case STEP3:
                changeWizardContent(Step3WhereDeploy(projectBuilder, exportModel))
            case STEP4:
                if (exportModel.deployMode == DeployMode.pushlet)
                {
                    changeWizardContent(Step4Pushlet(projectBuilder, exportModel))
                }
                else if (exportModel.deployMode == DeployMode.haystack)
                {
                    changeWizardContent(Step4Haystack(projectBuilder, exportModel))
                }
                else
                {
                    throw Err("Deploy mode not selected")
                }
        }

        relayout
    }

    private Str getPageMessage(Int currentPage)
    {
        return "Help message for page $currentPage"
    }

    private Bool canGotoPage(Int currentPage, Int newPage)
    {
        goingForward := newPage > currentPage

        switch (currentPage)
        {
            case STEP1:
                if (goingForward)
                {
                    return exportModel.sitesAndEquips.size > 0
                }
            case STEP3:
                if (goingForward)
                {
                    return exportModel.deployMode != null
                }
        }

        return true
    }

    private Void onCancel(Int currentPage)
    {
        close
    }

    private Void onFinish(Int currentPage)
    {
      //Code to export information, may package in Airhippo.pod
      if(exportModel.deployMode == DeployMode.pushlet) {
        File f := FileDialog{
          it.mode = FileDialogMode.saveFile
          filterExts = ["*.zip"]
          }.open(this)
        Zip zip := Zip.write(f.out)
        ziprecout := zip.writeNext(`/recs`)

        exportModel.sitesAndEquips.each |Record rec| {
          ziprecout.printLine(rec.id.toStr)
        }
        ziprecout.close
        zipconnout := zip.writeNext(`/conns`)
        exportModel.connections.each |ConnectionModel conn| {
          zipconnout.printLine(conn.connectionType.toStr+","+conn.deployment.toStr)
        }
        zipconnout.close
        zip.close
      }
        close
    }
}

class ExportModel
{
    Record[] sitesAndEquips := [,]
    DeployMode? deployMode := null
    ConnectionModel[] connections := [,]
}
