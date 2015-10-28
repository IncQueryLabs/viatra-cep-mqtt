package org.eclipse.viatra.cep.mqtt.midl.viatra

import java.io.File
import java.io.FileWriter
import org.eclipse.viatra.cep.mqtt.midl.mIDL.BooleanCriterion
import org.eclipse.viatra.cep.mqtt.midl.mIDL.Criterion
import org.eclipse.viatra.cep.mqtt.midl.mIDL.DataParameter
import org.eclipse.viatra.cep.mqtt.midl.mIDL.FloatCriterion
import org.eclipse.viatra.cep.mqtt.midl.mIDL.IntCriterion
import org.eclipse.viatra.cep.mqtt.midl.mIDL.Message
import org.eclipse.viatra.cep.mqtt.midl.mIDL.Sensor
import org.eclipse.viatra.cep.mqtt.midl.mIDL.StringCriterion
import org.eclipse.viatra.cep.mqtt.midl.utils.FileUtils

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
				«generateMessagePatterns(sensor.name.toFirstLower, message)»
			«ENDFOR»
		'''
		writer.write(fileContent)
		writer.close
	}

	private def generateMessagePatterns(String sensorName, Message message) '''
		«FOR parameter : message.dataParameters»
			«FOR criterion : parameter.criteria»
				«IF (criterion.prefix == "min" || criterion.prefix == "max")»
					«generateLessThanPattern(sensorName, message.name, parameter, criterion)»
					«generateGreaterThanPattern(sensorName, message.name, parameter, criterion)»
					«generateEqualsPattern(sensorName, message.name, parameter, criterion)»
				«ELSEIF (criterion.prefix == "eq" || criterion.prefix == "neq")»				
					«generateEqualsPattern(sensorName, message.name, parameter, criterion)»
					«generateNotEqualsPattern(sensorName, message.name, parameter, criterion)»
				«ENDIF»
			«ENDFOR»
		«ENDFOR»
		«FOR parameter : message.messageParameters»
			«generateMessagePatterns(sensorName, parameter.message)»
		«ENDFOR»
	'''

	private def generateLessThanPattern(String sensorName, String messageName, DataParameter parameter,
		Criterion criterion) '''
		
		pattern «sensorName»«messageName.toFirstUpper»«parameter.name.toFirstUpper»LessThan«criterion.prefix.toFirstUpper»Pattern(sensor: Sensor) {
			Sensor.messages.dataParameters(sensor, parameter);
			«parameter.type.toFirstUpper»Parameter.value(parameter, value);
			check(value < «getCriterionValue(criterion)»);
		}
	'''

	private def generateGreaterThanPattern(String sensorName, String messageName, DataParameter parameter,
		Criterion criterion) '''
		
		pattern «sensorName»«messageName.toFirstUpper»«parameter.name.toFirstUpper»GreaterThan«criterion.prefix.toFirstUpper»Pattern(sensor: Sensor) {
			Sensor.messages.dataParameters(sensor, parameter);
			«parameter.type.toFirstUpper»Parameter.value(parameter, value);
			check(value > «getCriterionValue(criterion)»);
		}
	'''

	private def generateEqualsPattern(String sensorName, String messageName, DataParameter parameter,
		Criterion criterion) '''
		
		pattern «sensorName»«messageName.toFirstUpper»«parameter.name.toFirstUpper»Equals«criterion.prefix.toFirstUpper»Pattern(sensor: Sensor) {
			Sensor.messages.dataParameters(sensor, parameter);
			«parameter.type.toFirstUpper»Parameter.value(parameter, value);
			check(value == «getCriterionValue(criterion)»);
		}
	'''

	private def generateNotEqualsPattern(String sensorName, String messageName, DataParameter parameter,
		Criterion criterion) '''
		
		pattern «sensorName»«messageName.toFirstUpper»«parameter.name.toFirstUpper»NotEquals«criterion.prefix.toFirstUpper»Pattern(sensor: Sensor) {
			Sensor.messages.dataParameters(sensor, parameter);
			«parameter.type.toFirstUpper»Parameter.value(parameter, value);
			check(value != «getCriterionValue(criterion)»);
		}
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
				«generateMessageRules(sensor.name.toFirstLower, message)»
			«ENDFOR»
		'''
		writer.write(fileContent)
		writer.close
	}

	private def generateMessageRules(String sensorName, Message message) '''
		«FOR parameter : message.dataParameters»
			«FOR criterion : parameter.criteria»
				«IF (criterion.prefix == "min" || criterion.prefix == "max")»
					«generateLessThanEventAndRule(sensorName, message.name, parameter, criterion)»
					«generateGreaterThanEventAndRule(sensorName, message.name, parameter, criterion)»
					«generateEqualsEventAndRule(sensorName, message.name, parameter, criterion)»
				«ELSEIF (criterion.prefix == "eq" || criterion.prefix == "neq")»				
					«generateEqualsEventAndRule(sensorName, message.name, parameter, criterion)»
					«generateNotEqualsEventAndRule(sensorName, message.name, parameter, criterion)»
				«ENDIF»
			«ENDFOR»
		«ENDFOR»
		«FOR parameter : message.messageParameters»
			«generateMessageRules(sensorName, parameter.message)»
		«ENDFOR»
	'''

	private def generateLessThanEventAndRule(String sensorName, String messageName, DataParameter parameter,
		Criterion criterion) '''
		
		queryEvent «sensorName»«messageName»«parameter.name.toFirstUpper»LessThan«criterion.prefix.toFirstUpper»Event() as
			«sensorName»«messageName»«parameter.name.toFirstUpper»LessThan«criterion.prefix.toFirstUpper»Pattern(_) found
		
		rule «sensorName»«messageName»«parameter.name.toFirstUpper»LessThan«criterion.prefix.toFirstUpper»Rule on «sensorName»«messageName»«parameter.name.toFirstUpper»LessThan«criterion.prefix.toFirstUpper»Event {
			println("«sensorName.toFirstUpper» «messageName» «parameter.name» «criterion.prefix» rule activated!")
		}
	'''

	private def generateGreaterThanEventAndRule(String sensorName, String messageName, DataParameter parameter,
		Criterion criterion) '''
		
		queryEvent «sensorName»«messageName»«parameter.name.toFirstUpper»GreaterThan«criterion.prefix.toFirstUpper»Event() as
			«sensorName»«messageName»«parameter.name.toFirstUpper»GreaterThan«criterion.prefix.toFirstUpper»Pattern(_) found
		
		rule «sensorName»«messageName»«parameter.name.toFirstUpper»GreaterThan«criterion.prefix.toFirstUpper»Rule on «sensorName»«messageName»«parameter.name.toFirstUpper»GreaterThan«criterion.prefix.toFirstUpper»Event {
			println("«sensorName.toFirstUpper» «messageName» «parameter.name» «criterion.prefix» rule activated!")
		}
	'''

	private def generateEqualsEventAndRule(String sensorName, String messageName, DataParameter parameter,
		Criterion criterion) '''
		
		queryEvent «sensorName»«messageName»«parameter.name.toFirstUpper»Equals«criterion.prefix.toFirstUpper»Event() as
			«sensorName»«messageName»«parameter.name.toFirstUpper»Equals«criterion.prefix.toFirstUpper»Pattern(_) found
		
		rule «sensorName»«messageName»«parameter.name.toFirstUpper»Equals«criterion.prefix.toFirstUpper»Rule on «sensorName»«messageName»«parameter.name.toFirstUpper»Equals«criterion.prefix.toFirstUpper»Event {
			println("«sensorName.toFirstUpper» «messageName» «parameter.name» «criterion.prefix» rule activated!")
		}
	'''

	private def generateNotEqualsEventAndRule(String sensorName, String messageName, DataParameter parameter,
		Criterion criterion) '''
		
		queryEvent «sensorName»«messageName»«parameter.name.toFirstUpper»NotEquals«criterion.prefix.toFirstUpper»Event() as
			«sensorName»«messageName»«parameter.name.toFirstUpper»NotEquals«criterion.prefix.toFirstUpper»Pattern(_) found
		
		rule «sensorName»«messageName»«parameter.name.toFirstUpper»NotEquals«criterion.prefix.toFirstUpper»Rule on «sensorName»«messageName»«parameter.name.toFirstUpper»NotEquals«criterion.prefix.toFirstUpper»Event {
			println("«sensorName.toFirstUpper» «messageName» «parameter.name» «criterion.prefix» rule activated!")
		}
	'''

}