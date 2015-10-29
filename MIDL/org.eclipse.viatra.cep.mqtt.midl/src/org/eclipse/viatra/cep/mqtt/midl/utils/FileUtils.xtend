package org.eclipse.viatra.cep.mqtt.midl.utils

import java.io.File
import java.util.regex.Pattern

class FileUtils {
	
	public static def createFolder(File file) {
		if (file != null && file.parentFile.exists) {
			if (!file.exists) {
				file.mkdir
			}
			return file
		}
		return null
	}
	
	public static def createFile(File folder, String name) {
		val file = new File(folder, name)
		if (file != null) {
			if (file.exists) {
				file.delete
			}
			file.createNewFile
		}
		return file
	}
	
	public static def createPackage(File sourceFolder, String packageName) {
		val packages = packageName.split(Pattern.quote("."))
		var actualPackage = sourceFolder
		for (p : packages) {
			val file = new File(actualPackage, p)
			createFolder(file)
			actualPackage = file
		}
		return actualPackage
	}
	
}