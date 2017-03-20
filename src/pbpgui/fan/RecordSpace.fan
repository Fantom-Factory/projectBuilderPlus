/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore

/*
  This class mixes with widgets etc where records are selectable so that other things can interact with said records
*/
mixin RecordSpace{
  virtual Record[] getSelectedPoints(){return [,]}
  virtual Record[] getSelectedEquips(){return [,]}
  virtual Record[] getSelectedSites(){return [,]}
  virtual Record[] getSelected(){return [,]}
}
