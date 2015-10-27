package org.eclipse.viatra.cep.mqtt.midl.viatra

import java.io.File
import java.io.FileWriter
import org.eclipse.viatra.cep.mqtt.midl.mIDL.BooleanCriterion
import org.eclipse.viatra.cep.mqtt.midl.mIDL.FloatCriterion
import org.eclipse.viatra.cep.mqtt.midl.mIDL.IntCriterion
import org.eclipse.viatra.cep.mqtt.midl.mIDL.Message
import org.eclipse.viatra.cep.mqtt.midl.mIDL.Sensor
import org.eclipse.viatra.cep.mqtt.midl.mIDL.StringCriterion
import org.eclipse.viatra.cep.mqtt.midl.utils.FileUtils
import org.eclipse.viatra.cep.mqtt.midl.mIDL.Criterion

class PatternGenerator {

	public def generatePatterns(Sensor sensor, String rootPath) {
		val projectFolder = new File(rootPath, "org.eclipse.viatra.cep.mqtt.generated.cep")
		val srcFolder = new File(projectFolder, "src")
		createPatterns(sensor, srcFolder)
		createViatraRules(sensor, srcFolder)
	}

	public def generateDefaultEiqFile(String rootPath) {
		val rootFolder = FileUtils.createFolder(rootPath)
		val projectFolder = FileUtils.createFolder(
			new File(rootFolder, "org.eclipse.viatra.cep.mqtt.generated.cep").absolutePath)
		val srcFolder = FileUtils.createFolder(new File(projectFolder, "src").absolutePath)
		val patternsFile = new File(srcFolder, "Patterns.eiq")
		val writer = new FileWriter(patternsFile)
		val fileContent = '''
			package org.eclipse.viatra.cep.mqtt.generated.cep.queries
			
			import "http://www.eclipse.org/viatra/cep/mqtt/midl/MIDL"
		'''
		writer.write(fileContent)
		writer.close
	}

	public def generateDefaultVeplFile(String rootPath) {
		val rootFolder = FileUtils.createFolder(rootPath)
		val projectFolder = FileUtils.createFolder(
			new File(rootFolder, "org.eclipse.viatra.cep.mqtt.generated.cep").absolutePath)
		val srcFolder = FileUtils.createFolder(new File(projectFolder, "src").absolutePath)
		val patternsFile = new File(srcFolder, "Events.vepl")
		val writer = new FileWriter(patternsFile)
		val fileContent = '''
			package org.eclipse.viatra.cep.mqtt.generated.cep.firstLevel
			
			import-queries org.eclipse.viatra.cep.mqtt.generated.cep.queries.*
		'''
		writer.write(fileContent)
		writer.close
	}

	private def createPatterns(Sensor sensor, File srcFolder) {
		val patternsFile = new File(srcFolder, "Patterns.eiq")
		val writer = new FileWriter(patternsFile, true)
		val fileContent = '''
			«FOR message : sensor.messages»
				«generateMessagePatterns(sensor.name, message)»
			«ENDFOR»
		'''
		writer.write(fileContent)
		writer.close
	}
	
	private def generateMessagePatterns(String sensorName, Message message) '''
		«FOR parameter:message.dataParameters»
			«FOR criterion : parameter.criteria»
				
				pattern «sensorName»«message.name.toFirstUpper»«parameter.name.toFirstUpper»«criterion.prefix.toFirstUpper»Pattern(sensor: Sensor) {
					Sensor.messages.dataParameters(sensor, parameter);
					«parameter.type.toFirstUpper»Parameter.value(parameter, value);
					«IF criterion.prefix == "min"»
						check(value < «getCriterionValue(criterion)»);
					«ELSEIF criterion.prefix == "max"»
						check(value > «getCriterionValue(criterion)»);
					«ELSEIF criterion.prefix == "eq"»
						check(value == «getCriterionValue(criterion)»);
					«ELSEIF criterion.prefix == "neq"»
						check(value != «getCriterionValue(criterion)»);
					«ENDIF»
				}
			«ENDFOR»
		«ENDFOR»
		«FOR parameter:message.messageParameters»
			«generateMessagePatterns(sensorName, parameter.message)»
		«ENDFOR»
	'''
	
	private def getCriterionValue(Criterion criterion) {
		if (criterion instanceof IntCriterion) {
			return criterion.value
		} else if (criterion instanceof FloatCriterion) {
			return criterion.value
		} else if (criterion instanceof StringCriterion) {
			return criterion.value
		} else if (criterion instanceof BooleanCriterion) {
			return criterion.value
		}
	}

	private def createViatraRules(Sensor sensor, File srcFolder) {
		val patternsFile = new File(srcFolder, "Events.vepl")
		val writer = new FileWriter(patternsFile, true)
		val fileContent = '''
			«FOR message : sensor.messages»
				«generateMessageRules(sensor.name, message)»
			«ENDFOR»
		'''
		writer.write(fileContent)
		writer.close
	}
	
	private def generateMessageRules(String sensorName, Message message) '''
		«FOR parameter:message.dataParameters»
			«FOR criterion : parameter.criteria»
				
				queryEvent «sensorName»«message.name.toFirstUpper»«parameter.name.toFirstUpper»«criterion.prefix.toFirstUpper»Event() as
					«sensorName»«message.name.toFirstUpper»«parameter.name.toFirstUpper»«criterion.prefix.toFirstUpper»Pattern(_) found
				
				rule «sensorName»«message.name.toFirstUpper»«parameter.name.toFirstUpper»«criterion.prefix.toFirstUpper»Rule on «sensorName»«message.name.toFirstUpper»«parameter.name.toFirstUpper»«criterion.prefix.toFirstUpper»Event {
					println("«sensorName.toFirstUpper» «message.name» «parameter.name» «criterion.prefix» rule activated!")
				}
			«ENDFOR»
		«ENDFOR»
		«FOR parameter:message.messageParameters»
			«generateMessageRules(sensorName, parameter.message)»
		«ENDFOR»
	'''

}