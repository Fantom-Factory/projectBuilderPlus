/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////



class SkysparkConnPool
{
  SkysparkConn[] conns := [,]

  Void addConn(SkysparkConn conn)
  {
    conns.add(conn)
  }

  Void deleteConn(SkysparkConn conn)
  {
    conns.remove(conn)
  }


}
