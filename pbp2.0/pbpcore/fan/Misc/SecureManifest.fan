/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////



class SecureManifest
{
  static Void savePassword(Str projectName, Record rec, Str password)
  {
    Str secret := "NOTsoSecretgrapeFruit#2334"
    Str:Str passwordFile := (FileUtil.getProjectHomeDir(projectName)+`pw.p`).readObj
    passwordFile.set(rec.id.toStr,Crypto().encode(password,secret))
    (FileUtil.getProjectHomeDir(projectName)+`pw.p`).writeObj(passwordFile)
  }

 static Void removePassword(Str projectName, Record? rec)
  {
    Str secret := "NOTsoSecretgrapeFruit#2334"
    Str:Str passwordFile := (FileUtil.getProjectHomeDir(projectName)+`pw.p`).readObj
    passwordFile.remove(rec.id.toStr)
    (FileUtil.getProjectHomeDir(projectName)+`pw.p`).writeObj(passwordFile)
  }
}
