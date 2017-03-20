/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

class RefreshRepo : Command
{
  Manager manager
  new make(Manager manager) : super.makeLocale(Pod.of(this),"refreshRepo")
  {
    this.manager = manager
  }
  override Void invoked(Event? event)
  {
    manager.refreshRepo
    RepoWindow repoWindow := event.window
    (repoWindow.repoTable.model as ProgramTableModel).update
    repoWindow.repoTable.refreshAll
  }
}

class DownloadPod : Command
{
  Manager manager
  new make(Manager manager) : super.makeLocale(Pod.of(this), "downloadPod")
  {
    this.manager = manager
  }
  override Void invoked(Event? event)
  {
    RepoWindow repoWindow := event.window
    File[] targetFiles := (repoWindow.repoTable.model as ProgramTableModel).getRows(repoWindow.repoTable.selected)
    //TODO: notify whats about to happen here..
    targetFiles.each |file|
    {
      manager.downloadPod(file)
    }
  }
}

class InstallPod : Command
{
  Manager manager
  new make(Manager manager) : super.makeLocale(Pod.of(this), "installPod")
  {
    this.manager = manager
  }

  override Void invoked(Event? event)
  {
    RepoWindow repoWindow := event.window
    File[] targetFiles := (repoWindow.repoTable.model as ProgramTableModel).getRows(repoWindow.repoTable.selected)
    Str:Program installedFiles := [:]
    Pod.list.each |pod|
    {
      installedFiles.add(pod.name, Program{it.name=pod.name; version=pod.version})
    }

    targetFiles.each |file|
    {
      Str podname := file.basename.split('-')[0]
      Str podversion := file.basename.split('-')[1]
      if(file.ext == "pod" || installedFiles.containsKey(podname) && !(installedFiles[podname].version > Version.fromStr(podversion)))
      {
        manager.installPod(file)
      }
    }

    Dialog.openInfo(event.window, "Please restart Project Builder Plus for changes to come into effect. Project Builder will now shut down. Thank you")
    Env.cur.exit
  }
}
