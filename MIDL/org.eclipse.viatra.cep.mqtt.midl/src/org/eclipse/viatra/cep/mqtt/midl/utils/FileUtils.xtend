package org.eclipse.viatra.cep.mqtt.midl.utils

import java.io.File

class FileUtils {
	
	public static def createFolder(String path) {
		val file = new File(path)
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
	
}