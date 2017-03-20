/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpgui
using pbpcore
using pbpi

using fwt
using gfx
using concurrent

class ProjectBuilder : PbpListener
{
  internal Licensing licensing := Licensing()
  const LicenseInfo licenseInfo

  Builder builder
  Project? currentProject
  Str:Project projects := [:]
  //Standard widgets that will never change.. will become read-only after everything else is instantiated
  Str:Obj? coreWidgets := [:]
  //Aux map for use by extentions
  Str:Obj? auxWidgets := [:]

  const Str projectExpHandle := Uuid().toStr
  const Str siteExpHandle  := Uuid().toStr
  const Str equipExpHandle := Uuid().toStr
  const Str pointExpHandle := Uuid().toStr
  const Str standardTagsExpHandle := Uuid().toStr
  const Str customTagsExpHandle := Uuid().toStr
  const Str templateExpHandle := Uuid().toStr
  const Str templateTypeHandle := Uuid().toStr
  const Str toolsMenuHandle := Uuid().toStr
  Watcher[] projectChangeWatchers := [,]

  ** Conn providesrs (PbpConnExt inctances) keys by name
  Str:ConnProvider connProviders:= [:]

  //const ProgressHandler phandler

  UiUpdater? helpMenuUiUpdater

  // Nav Name Func Executor
  Func? navNameFuncExecutor

  new make()
  {

    try
    {
      if( ! licensing.checkLicense) { throw InvalidLicenseErr() }
    }
    finally
    {
        this.licenseInfo = LicenseInfo(licensing)
    }

    builder = Builder()
   // phandler = ProgressHandler(builder._pbar, Label(), ActorPool())
    init();
    builder.title = Pod.of(this).meta["pbp.name"] + " " + Pod.of(this).version
    builder.icon = Desktop.isMac?PBPIcons.pbpIcon64:PBPIcons.pbpIcon64
    builder.onClose.add |e|
    {
      //indexer.close
    }
  }

  static Void start()
  {
    ProjectBuilder? newPBP := null

    try
    {
        newPBP = ProjectBuilder()
    }
    catch (InvalidLicenseErr e)
    {
        return
    }

    tagService := Service.find(TagService#, false) as TagService
    if (tagService == null)
    {
        TagService newTagService := TagService(FileUtil.getTagPriorityFile())
        newTagService.install.start

        Env.cur.addShutdownHook |->|
        {
            newTagService.stop
        }
    }
    else
    {
        tagService.onStop()
        tagService.onStart()
    }

    newPBP.builder.open()
  }

  private Void init()
  {
     initConns()
     initMenu()
     initMiddle()
     initTags()
     initTemplates()
     initAux()
     initServiceExt
     addLogicLayer()
     coreWidgets = coreWidgets.ro //lock core widgets up
  }

  private Void initToolbarExts()
  {
    ToolbarExt.initToolbarExts([
        "siteToolbar": RecordExplorerToolbarCommandAdder(coreWidgets[siteExpHandle] as RecordExplorer ?: throw Err("Invalid state: siteExpHandle")),
        "equipToolbar": RecordExplorerToolbarCommandAdder(coreWidgets[equipExpHandle] as RecordExplorer ?: throw Err("Invalid state: equipExpHandle")),
        "pointToolbar": RecordExplorerToolbarCommandAdder(coreWidgets[pointExpHandle] as RecordExplorer ?: throw Err("Invalid state: pointExpHandle"))
    ], [this])
  }

  private Void initConns()
  {
    File connDir := Env.cur.homeDir+`exts/conn/`
    Pod[] connPods := Pod.list.findAll |Pod pod -> Bool| {return pod.meta.containsKey("pbpconnext")}
    connPods.each |pod|
    {
    /*
      InStream podin := pod.in
      Pod newconnpod := Pod.load(podin)
      podin.close
      */
      instance := pod.type("PbpConnExt").make([this])
      Widget newwidget := instance->getTab()
      //widgets.add(newwidget.hash,newwidget)
      builder._connTabs.add(newwidget)
      {
        if(instance.typeof.fits(ConnProvider#))
        {
          p := instance as ConnProvider
          connProviders[p.name] = p
        }
      }
    }
  }

  private Void initMenu()
  {
     HelpMenu helpMenu := HelpMenu()
     helpMenuUiUpdater = UiUpdater(helpMenu,Main.helpMenuWatcher)
     helpMenuUiUpdater.send(null)


     Menu toolsMenu := Menu{text="Tools"}
     coreWidgets[toolsMenuHandle] = toolsMenu
     toolsMenu.add(MenuItem(ManageTrees(this)))
     toolsMenu.add(MenuItem(Command("Manage History Remove", null) |Event e| {
      EditTagLib(this).edit(e.window, Env.cur.homeDir+`resources/tags/hisremove.taglib`)
     }))
     toolsMenu.add(MenuItem(Skyspark2NiagaraCommand(this)))


     fileMenu := Menu() {
        text="File"
        MenuItem(AddProject(this)),
        MenuItem(Open()),
        MenuItem(Save(this)),
     }

     //TODO: Fill in implementation!
     builder.menuBar = Menu() {fileMenu, toolsMenu, helpMenu, }

     MenuExt.initMenuExts(fileMenu, toolsMenu, helpMenu, [this])
  }

  private Void initServiceExt()
  {
    if(coreWidgets.containsKey(toolsMenuHandle))
    {
      Pod[] servicePods := Pod.list.findAll |Pod pod -> Bool| {
        return pod.meta.containsKey("pbpserviceext")
      }
      Menu toolsMenu := coreWidgets[toolsMenuHandle]

      servicePods.each |pod|
      {
        MenuItem[] items := pod.type("PbpServiceExt").make([this])->getMenuItems()
        items.each |item|
        {
          toolsMenu.add(item)
        }
      }
    }
  }

  private Void initMiddle()
  {
    //Register Widgets for later use...
    //TODO: Fill in implementation!
    coreWidgets[projectExpHandle] = ProjectExplorer(Env.cur.homeDir + `projects/`, this)

    //TODO: Fill in implementation!
    coreWidgets[siteExpHandle] = RecordExplorer(this)
    (coreWidgets[siteExpHandle] as RecordExplorer).addOnPopupTableAction |Event e|
    {
      e.popup = PbpUtil.makeRecTablePopup(this, e, currentProject.database.getClassMap(Site#))
    }

    //TODO: Fill in implementation!
    coreWidgets[equipExpHandle] = RecordExplorer(this)
    (coreWidgets[equipExpHandle] as RecordExplorer).addOnPopupTableAction |Event e|
    {
      e.popup = PbpUtil.makeRecTablePopup(this, e, currentProject.database.getClassMap(Equip#))
    }

    //TODO: Fill in implementation!
    coreWidgets[pointExpHandle] = RecordExplorer(this)
    (coreWidgets[pointExpHandle] as RecordExplorer).addOnPopupTableAction |Event e|
    {
      e.popup = PbpUtil.makeRecTablePopup(this, e, currentProject.database.getClassMap(pbpcore::Point#))
    }

    //Add Widgets To Builder...
    //TODO: add Icons here
    builder._recordTabs.add(Tab{ image = PBPIcons.projectTabIcon32; text="Explorer"; coreWidgets[projectExpHandle],})
    builder._recordTabs.add(Tab{ image = PBPIcons.siteTab32; text="Sites";  coreWidgets[siteExpHandle],})
    builder._recordTabs.add(Tab{ image = PBPIcons.equipmentTab32; text="Equips"; coreWidgets[equipExpHandle],})
    builder._recordTabs.add(Tab{ image = PBPIcons.pointTab32; text="Points"; coreWidgets[pointExpHandle],})

  }



 private Void initTags()
 {
    //TODO: Fill in implementation!
    tagExplorer := TagExplorer(FileUtil.getTagDir+`standard.taglib`, null, true)
    tagExplorer.addBtnCommand(AddTagToRecord(this, tagExplorer))
    coreWidgets[standardTagsExpHandle] = tagExplorer

    //TODO: Fill in implementation!
    tagExplorer = TagExplorer.makeWithToolbarAndCombo(
        FileUtil.getTagDir.listFiles.find|File f->Bool|{return f.ext=="taglib"},
        null,
        TagCommands(this).getToolbar,
        TagUtil().getTagLibCombo,
        true)
    tagExplorer.addBtnCommand(AddTagToRecord(this, tagExplorer))

    coreWidgets[customTagsExpHandle] = tagExplorer

    builder._tagTabs.add(Tab{ image = PBPIcons.skysparkTags32; text="Standard Tags"; coreWidgets[standardTagsExpHandle],})
    builder._tagTabs.add(Tab{ image = PBPIcons.pbpCustomTags32; text="Custom Tags"; coreWidgets[customTagsExpHandle],})
 }

 private Void initTemplates()
 {
   //TODO: Fill in implementation!
   coreWidgets[templateExpHandle] = TemplateExplorer(TemplateTableModel(), TemplateCommands(this).getTemplateToolbar(), DeployTemplate(this))
   (coreWidgets[templateExpHandle] as TemplateExplorer).addOnTableAction(|Event e| { EditTemplate(this).invoked(e) })

   coreWidgets[templateTypeHandle] = TemplateExplorer(TemplateTypeTableModel(), TemplateCommands(this).getToolbar, Templatize(this))

    builder._templateTabs.add(Tab{ text="Templates"; coreWidgets[templateExpHandle],})
    builder._templateTabs.add(Tab{ text="Template Types"; coreWidgets[templateTypeHandle],})
 }

 private Void initAux()
 {
   Table changeTable := Table{
     model=ChangesetTableModel(this)
     onAction.add |e| {
       ViewChangesetCommand(this).invoked(e)
      }
   }
   ChangeTableUpdater(changeTable, getProjectChangeWatcher).send("START")
    builder._auxTabs.add(Tab{ text="Changesets"; changeTable,})
    //builder._auxTabs.add(Tab{ text="Weather"})
 }
//TODO: Decouple this later? Encapsulate a new class with similar names..
  private Void addLogicLayer()
  {
    (coreWidgets[siteExpHandle] as RecordExplorer).addToolbarCommand(RecordCommands.addSite(this))
    (coreWidgets[equipExpHandle] as RecordExplorer).addToolbarCommand(RecordCommands.addEquip(this))
    (coreWidgets[pointExpHandle] as RecordExplorer).addToolbarCommand(RecordCommands.addPoint(this))

    initToolbarExts()

    //TODO: Hide this in a function..
    (coreWidgets[projectExpHandle] as ProjectExplorer).addOnTableSelectHandler |Event e|
    {
      //TODO: put this stuff in a event handler of a window with it's main body of a progressBar of indeterminate value.
      switchToSelectedProject()
    }

    (coreWidgets[siteExpHandle] as RecordExplorer).addOnTableAction |Event e|
    {
       EditRec(this).invoked(e)
    }

    (coreWidgets[equipExpHandle] as RecordExplorer).addOnTableAction |Event e|
    {
       EditRec(this).invoked(e)
    }

    (coreWidgets[pointExpHandle] as RecordExplorer).addOnTableAction |Event e|
    {
       EditRec(this).invoked(e)
    }

    coreWidgets[templateTypeHandle]->templateTable->onAction->add |e|
    {
      EditTemplateType(this).invoked(e)
    }
  }

  Void switchToSelectedProject()
  {
    selected := (coreWidgets[projectExpHandle] as ProjectExplorer).getSelected
    if (selected.size > 0) {
      projectName := selected.first.basename
      
      if (!projects.containsKey(projectName))
      {
        projects.add(projectName, Project(projectName))
      }
      
      currentProject = projects[projectName]
      
      switchProjectUi()
      projectChange()
    }
  }

  public Void switchProjectUi()
  {
    coreWidgets[siteExpHandle]->setTableModel(RecTableModel(currentProject.database.getClassMap(Site#), currentProject))
    coreWidgets[equipExpHandle]->setTableModel(RecTableModel(currentProject.database.getClassMap(Equip#), currentProject))
    coreWidgets[pointExpHandle]->setTableModel(RecTableModel(currentProject.database.getClassMap(pbpcore::Point#), currentProject))
    builder._treeTabs.tabs.each |tab|
    {
      builder._treeTabs.remove(tab)
    }
    currentProject.rectrees.each |rectree|
    {
      ToolBarTree treewidget := TreeWidget(this, rectree)
      builder._treeTabs.add(Tab{ text=rectree->treename; treewidget,})
    }
  }
  public Watcher getProjectChangeWatcher()
  {
    projectChangeWatchers.push(Watcher())
    return projectChangeWatchers.peek()
  }

  public Void projectChange()
  {
    projectChangeWatchers.each |watcher|
    {
      watcher.set()
    }
    return
  }

//  public Bool checkLicenseLimit(Int val)
//  {
//    return licensing.checkLicenseLimit(val)
//  }
//
//  public Str:Str getSasHosts()
//  {
//    return licensing.skysparkHostIds
//  }
//
//  public Bool isUnlimitedSas()
//  {
//    return licensing.unlimitedSas
//  }

  public PbpWorkspace asWorkspace()
  {
    return PbpWorkspace(
      coreWidgets, projectExpHandle, siteExpHandle, equipExpHandle,
      pointExpHandle, standardTagsExpHandle, customTagsExpHandle, templateExpHandle, templateTypeHandle)
  }

  ** Used for UI callbacks without a dependency
  override Obj? callback(Str id, Obj?[] args := [,])
  {
    switch(id)
    {
      case "getBuilder" :
        return builder
      case "getConnProviders" :
        return connProviders
      case "getCurProject" :
        return currentProject
      case "getWorkspace" :
        return asWorkspace
      case "setCurProject" :
        currentProject = args[0]
      case "getCoreWidgets":
        return coreWidgets
      case "getAuxWidgets" :
        return auxWidgets
      case "removeProject" :
        projects.remove(args[0])
      case "runNavNameFunc":
        runNavNameFuncs(args[1])
      case "projectsRemoved":

        projectsRemoved(args[0] as File[])

      default:
        throw Err("Unexpected listener message: $id")
    }
    return null
  }

  Void runNavNameFuncs(Event e) {
    navNameFuncExecutor(e)
  }

  ** Get a tab by it's display text (name)
  Tab getTabByName(Str name)
  {
    return builder._connTabs.children.find |Widget w, Int index -> Bool|
    {
      tab := w as Tab
      return tab?.text?.lower == name.lower
    }
  }

  ** Get current Obix conns
  Conn[] obixConns()
  {
    return connProviders["ObixConnProvider"].conns
  }

  ** Get current Skyspark conns
  Conn[] skysparkConns()
  {
    return connProviders["SkysparkConnProvider"].conns
  }

    RecordExplorer getSiteToolbar()
    {
        return coreWidgets[siteExpHandle] as RecordExplorer ?: throw Err("Invalid state: siteExpHandle")
    }

    RecordExplorer getEquipToolbar()
    {
        return coreWidgets[equipExpHandle] as RecordExplorer ?: throw Err("Invalid state: equipExpHandle")
    }

    RecordExplorer getPointToolbar()
    {
        return coreWidgets[pointExpHandle] as RecordExplorer ?: throw Err("Invalid state: pointExpHandle")
    }

    ProjectExplorer getProjectExplorer()
    {
        return coreWidgets[projectExpHandle] as ProjectExplorer ?: throw Err("Invalid state: projectExpHandle")
    }

    override Bool isSiteRecordsExplorer(Obj? widget) { return widget is RecordExplorer && widget === getSiteToolbar() }

    override Bool isEquipRecordsExplorer(Obj? widget) { return widget is RecordExplorer && widget === getEquipToolbar() }

    override Bool isPointRecordsExplorer(Obj? widget) { return widget is RecordExplorer && widget === getPointToolbar() }

    override Bool isQueryRecordsExplorer(Obj? widget) { return auxWidgets["latestwb"] === widget }


    Void projectsRemoved(File[]? files)
    {
        restart()
    }

    Void restart()
    {
        // keep FWT's gfx env
        gfxEnv := Actor.locals["gfx.env"]
        Actor.locals.clear
        Actor.locals["gfx.env"] = gfxEnv

        helpMenuUiUpdater.stop.getAndSet(true)
        Main.restart.getAndSet(true)
        builder.close()
     }

}


