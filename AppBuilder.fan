
class Main {
	static Void main() {
		AppBuilder("projectBuilder") {
			it.useEnvForPods	= true
			it.useEnvForFiles	= false
			it.fantomHomeDir	= File.os("fantom-1.0.65")
			it.jarFiles			= ["swt.jar"]

		}.build |AppBuilder bob| {
			bob.copyPod("icons"				, false, false)
			bob.copyPod("airship"			, false, false)
			bob.copyPod("pbptrendimporter"	, false, false)

			bob.copyPod("pbpairship"	, false, false)
			bob.copyPod("pbpaximport"	, false, false)
			bob.copyPod("pbpdishandler"	, false, false)
			bob.copyPod("pbpexport"		, false, false)
			bob.copyPod("pbpfile"		, false, false)
			bob.copyPod("pbpmdbimport"	, false, false)
			bob.copyPod("pbpnhaystack"	, false, false)
			bob.copyPod("pbpobix"		, false, false)
			bob.copyPod("pbpquery"		, false, false)
			bob.copyPod("pbpskyspark"	, false, false)
			bob.copyPod("pbpsql"		, false, false)
			bob.copyPod("pbptagging"	, false, false)
			bob.copyPod("pbptools"		, false, false)
			bob.copyPod("pbpzincexport"	, false, false)

			// copy over Fantom v1.0.65 libs
			(bob.fantomHomeDir + `lib/fan/`).listFiles.each {
				file := bob._distDir + `lib/fan/${it.name}`
				if (file.exists) {
					bob.copyFile(it, `lib/fan/`, true)
				}
			}

			bob.copyFile(`etc/`.toFile, `etc/`)
			bob.copyFile(`resources/`.toFile, `resources/`)
			bob.copyFile(`lib/java/ext/commons-lang-2.6.jar`.toFile, `lib/java/ext/`)
			bob.copyFile(`lib/java/ext/commons-logging-api-1.1.jar`.toFile, `lib/java/ext/`)
			bob.copyFile(`lib/java/ext/haystack-java-1.0.0.jar`.toFile, `lib/java/ext/`)
			bob.copyFile(`lib/java/ext/jackcess-2.0.4.jar`.toFile, `lib/java/ext/`)
			bob.copyFile(`lib/java/ext/lucene-core-3.6.1.jar`.toFile, `lib/java/ext/`)
		}
	}
}



// ---- Do not edit below this line ---------------------------------------------------------------

** Fantom App Builder v0.0.4
** =========================
** Creates a standalone Fantom application installation with the minimum number of files.
**
** v0.0.4 - Added 'findPodFile()' to make work with Fantom Pod Manager.
** v0.0.2 - Initial release.
**
class AppBuilder {

	** The name of the main application pod.
	const Str podName

	** The directory where the application is assembled.
	** Defaults to 'build/'
	const File buildDir

	** If 'true' (the default), then files (pods and libraries) are located using the current 'Env'.
	** If 'false', files are taken to be relative to the 'fantomHomeDir'.
	**
	** See 'findFile()' method.
	const Bool useEnvForPods := true

	const Bool useEnvForFiles := true

	** The Home directory of the Fantom installation.
	** If 'useEnv' is 'false' then all pods and libraries are taken from this location.
	** Defaults to `sys::Env.homeDir`.
	**
	**   fantomHomeDir = File.os("C:\\Apps\\fantom-1.0.68\\")
	const File fantomHomeDir := Env.cur.homeDir

	** Names of pods that should not be included in the distribution.
	**
	**   excludePods = ["compiler"]
	const Str[] excludePods := Str[,]

	** A list of java libraries (jar file names) that are to be copied over.
	** Jar files are copied from 'lib/java/ext/' and 'lib/java/ext/XXXX/' where 'XXXX' is a matching platform name.
	** See 'platforms' field for details.
	**
	**   jarFiles = ["swt.jar"]
	const Str[] jarFiles := Str[,]

	** A list of platforms (regex globs) that '.jar' files will be copied over for. Use to target specific platforms:
	**
	**   platforms = ["win32-x86*"]  // is the same as
	**   platforms = ["win32-x86", "win32-x86_64"]
	**
	** Defaults to 'Str["*"]' which targets *all* platforms.
	const Str[] platforms := Str["*"]

	** Arguments to pass to the fantom launch scripts.
	**
	** Defaults to 'podName' to launch the application.
	const Str scriptArgs

	const File _distDir

	** Creates an instance of 'AppBuilder' for the given pod.
	new make(Str podName, |This|? in := null) {
		this.podName = podName
		this.buildDir = File(typeof->sourceFile.toStr.toUri).normalize.parent + `build/`
		in?.call(this)

		if (!buildDir.isDir)
			throw ArgErr("buildDir is NOT a directory - ${buildDir.normalize.osPath}")
		if (!fantomHomeDir.isDir)
			throw ArgErr("fantomHomeDir is NOT a directory - ${fantomHomeDir.normalize.osPath}")

		this.buildDir = this.buildDir.normalize
		this._distDir = this.buildDir + `${podName}-${Pod.find(podName).version}/`

		if (scriptArgs == null)
			scriptArgs = podName
	}

	** Builds the packaged installation.
	** 'extra' is called before the .zip file is created to allow you to perform any extra tasks;
	** such as copying over surplus files.
	Void build(|AppBuilder|? extra := null) {
		pod  := Pod.find(podName)
		name := (pod.meta["pod.dis"] ?: podName) + " ${pod.version}"
		log
		log("Packaging ${name}")
		log("".padl(name.size+10, '='))

		// clean
		if (_distDir.exists) {
			log("\nDeleting `${_distDir.osPath}`...")
			_distDir.delete
		}
		_distDir.create

		// copy java runtime
		log("\nCopying Java runtime...")
		copyFile(findFile(`lib/java/sys.jar`), `lib/java/`)

		// copy pods
		log("\nCopying application pods...")
		copyPod(podName)

		// copy jars
		if (jarFiles.size > 0) {
			log("\nCopying jar files...")
			copyJarFiles(jarFiles, platforms)
		}

		log("\nCreating script files...")
		createScriptFiles(podName, scriptArgs)

		if (extra != null) {
			log("\nCalling user function...")
			extra.call(this)
		}

		zipName := `${podName}-${Pod.find(podName).version}.zip`
		log("\nCompressing to ${zipName} ...")
		zipFile := compressToZip(_distDir, zipName)
		log("   - ${zipFile.osPath}")
		//_distDir.delete

		log("\nDone.")
	}

	** Copies over jar file from the existing Fantom environment.
	** The parameters have the same meaning as `jarFiles` and `platforms`.
	Void copyJarFiles(Str[] jarFiles, Str[] platformGlobs) {
		jarFiles.each |jarFileName| {
			copyFile(findFile(`lib/java/ext/${jarFileName}`, false), `lib/java/ext/`)

			extDir := findFile(`lib/java/ext/`, false)
			if (extDir != null) {
				platformGlobs.each |platform| {
					extDir.listDirs(Regex.glob(platform)).each |libDir| {
						copyFile(findFile(`lib/java/ext/${libDir.name}/${jarFileName}`, false), `lib/java/ext/${libDir.name}/`)
					}
				}
			}
		}
	}

	** Copies over the named pod, along with all (transitive) dependencies and any associated 'etc/' property directory.
	Void copyPod(Str podName, Bool copyEtcFiles := true, Bool copyDependencies := true) {
		podNames := copyDependencies ? _findPodDependencies(Str[,], podName).unique : [podName]

		podNames.unique.each |pod| {
			// log versions of non-core pods
			ver := Pod.find(pod).version == Pod.find("sys").version ? "" : " (v${Pod.find(pod).version})"
			_copyFile(findPodFile(pod, true), `lib/fan/${pod}.pod`, false, ver)
		}

		if (copyEtcFiles)
			podNames.unique.each |pod| {
				copyFile(findFile(`etc/${pod}/`, false), `etc/${pod}/`)
			}
	}

	** Copies the given file to the destination URL - which is relative to the output folder.
	** Returns the destination file, or null if 'srcFile' is 'null' or does not exist.
	**
	**   copyFile(`fan://acme/res/config.props`.get, `etc/config.props`)
	**
	** If 'srcFile' is a dir, then the entire directory tree is copied over.
	**
	** If 'destUrl' is a dir, then the file is copied into it.
	File? copyFile(File? srcFile, Uri destUri, Bool overwrite := false) {
		_copyFile(srcFile, destUri, overwrite, Str.defVal)
	}

	** Compresses the given file to a .zip file at the destination URL- which is relative to the output folder.
	** Returns the compressed .zip file.
	**
	** 'toCompress' may be a directory.
	File compressToZip(File toCompress, Uri destUri) {
		if (destUri.isDir)
			throw ArgErr("Destination can not be a directory - ${destUri}")
		if (!destUri.isPathOnly)
			throw ArgErr(_msg_urlMustBePathOnly("destUri", destUri, `my-app.zip`))
		if (destUri.isPathAbs)
			throw ArgErr(_msg_urlMustNotStartWithSlash("destUri", destUri, `my-app.zip`))

		bufferSize := 16*1024
		dstFile := (buildDir + destUri).normalize
		zip  	:= Zip.write(dstFile.out(false, bufferSize))
		// DO include the name of the containing folder in zip paths
		parentUri := toCompress.parent.uri
		// do NOT include the name of the containing folder in zip paths
		//parentUri := toCompress.isDir ? toCompress.uri : toCompress.parent.uri
		try {
			toCompress.walk |src| {
				if (src.isDir) return
				path := src.uri.relTo(parentUri)
				out  := zip.writeNext(path)
				try {
					src.in(bufferSize).pipe(out)
				} finally
					out.close
			}
		} finally
			zip.close

		return dstFile
	}

	** Creates basic script files to launch the application.
	Void createScriptFiles(Str baseFileName, Str scriptArgs) {
		copyFile(findFile(`bin/fanlaunch`, true), `fanlaunch`)
		bshScript 	:= "#!/bin/bash\n\nexport FAN_HOME=.\nunset FAN_ENV\n. \"\${0%/*}/fanlaunch\"\nfanlaunch Fan ${scriptArgs} \"\$@\""
		bshFile 	:= (_distDir + `${baseFileName}`).normalize.out.writeChars(bshScript).close
		log("  - copied ${baseFileName}")
		cmdScript	:= "@set FAN_HOME=.\n@set FAN_ENV=\n@java -cp \"%FAN_HOME%\\lib\\java\\sys.jar\" fanx.tools.Fan ${scriptArgs} %*"
		cmdFile 	:= (_distDir + `${baseFileName}.bat`).normalize.out.writeChars(cmdScript).close
		log("  - copied ${baseFileName}.bat")
	}

	** Resolves a file based on the given relative URI.
	** If 'useEnv' is 'true' then 'Env.cur.findFile(...)' is used to find the file, otherwise it is
	** taken to be relative to 'fantomHomeDir'.
	File? findPodFile(Str podName, Bool checked := true) {
		if (useEnvForPods)
			return Env.cur.findPodFile(podName) ?: (checked ? throw ArgErr("Could not find pod file for ${podName}") : null)
		file := (fantomHomeDir + `lib/fan/${podName}.pod`).normalize
		return file.exists ? file : (checked ? throw ArgErr("File not found - ${file}") : null)
	}

	** Resolves a pod file based on its name.
	** If 'useEnv' is 'true' then 'Env.cur.findFile(...)' is used to find the file, otherwise it is
	** taken to be relative to 'fantomHomeDir'.
	File? findFile(Uri fileUri, Bool checked := true) {
		if (useEnvForFiles)
			return Env.cur.findFile(fileUri, checked)
		if (fileUri.isPathAbs)
			throw ArgErr(_msg_urlMustNotStartWithSlash("fileUri", fileUri, `etc/config.props`))
		file := (fantomHomeDir + fileUri).normalize
		return file.exists ? file : (checked ? throw ArgErr("File not found - ${file}") : null)
	}

	** Echos the msg.
	static Void log(Obj? msg := "") {
		echo(msg?.toStr ?: "null")
	}

	private File? _copyFile(File? srcFile, Uri destUri, Bool overwrite, Str append) {
		if (!destUri.isPathOnly)
			throw ArgErr(_msg_urlMustBePathOnly("destUri", destUri, `etc/config.props`))
		if (destUri.isPathAbs)
			throw ArgErr(_msg_urlMustNotStartWithSlash("destUri", destUri, `etc/config.props`))

		if (srcFile == null)
			return null
		if (!srcFile.exists) {
			log("Src file does not exist: ${srcFile?.normalize?.osPath}")
			return null
		}

		if (destUri.isDir && !srcFile.isDir)
			destUri = destUri.plusName(srcFile.name)

		dstFile := (_distDir + destUri).normalize
		srcFile.copyTo(dstFile, ["overwrite": overwrite])
		log("  - copied " + dstFile.uri.relTo(_distDir.uri).toFile.osPath + append)
		return dstFile
	}

	private Str[] _findPodDependencies(Str[] podNames, Str podName) {
		if (!excludePods.contains(podName) && !podNames.contains(podName)) {
			podNames.add(podName)
			pod := Pod.find(podName)
			pod.depends.each |depend| {
				_findPodDependencies(podNames, depend.name)
			}
		}
		return podNames
	}

	private static Str _msg_urlMustBePathOnly(Str type, Uri url, Uri example) {
		"${type} URL `${url}` must ONLY be a path. e.g. `${example}`"
	}

	private static Str _msg_urlMustNotStartWithSlash(Str type, Uri url, Uri example) {
		"${type} URL `${url}` must NOT start with a slash. e.g. `${example}`"
	}
}
