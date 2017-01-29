/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent

abstract class SqlProcessor
{
  abstract SqlPackageEditPane[] getEditPanes(AtomicRef listRef)
  abstract SqlPackage processEditPane(SqlPackageEditPane editPane) //TODO: temproary return type of nullable
}
