/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using haystack

class ChangeFactory
{
   static Change getNewTagChange(Ref target, Tag tag)
    {
      return Change{
        id = CID.ADDTAG
        it.target = target
        opts = [tag]
      }
    }

    static Change getDelTagChange(Ref target, Tag tag)
    {
      return Change{
        id = CID.REMOVETAG
        it.target = target
        opts = [tag]
      }
    }

    static Change getModTagChange(Ref target, Tag tag)
    {
      return Change{
        id= CID.MODTAG
        it.target = target
        opts = [tag]
        }
    }

}
