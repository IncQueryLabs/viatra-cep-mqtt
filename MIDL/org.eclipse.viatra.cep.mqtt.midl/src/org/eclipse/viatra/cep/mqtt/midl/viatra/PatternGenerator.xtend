package org.eclipse.viatra.cep.mqtt.midl.viatra

import java.io.File
import java.io.FileWriter
import org.eclipse.emf.common.util.EList
import org.eclipse.viatra.cep.mqtt.midl.mIDL.BooleanCriterion
import org.eclipse.viatra.cep.mqtt.midl.mIDL.Criterion
import org.eclipse.viatra.cep.mqtt.midl.mIDL.DataParameter
import org.eclipse.viatra.cep.mqtt.midl.mIDL.DoubleCriterion
import org.eclipse.viatra.cep.mqtt.midl.mIDL.IntCriterion
import org.eclipse.viatra.cep.mqtt.midl.mIDL.Message
import org.eclipse.viatra.cep.mqtt.midl.mIDL.Sensor
import org.eclipse.viatra.cep.mqtt.midl.mIDL.StringCriterion
import org.eclipse.viatra.cep.mqtt.midl.utils.FileUtils

class PatternGenerator {

	public  def generatePatternsAndRules(File cepTopPackage, EList<Sensor> sensors) {
		generatePatterns(cepTopPackage, sensors)
		generateRules(cepTopPackage, sensors)
	}

	private def generatePatterns(File cepTopPackage, EList<Sensor> sensors) {
		val eiqPackage = FileUtils.createFolder(new File(cepTopPackage, "eiq"))
		val patternsFile = new File(eiqPackage, "Patterns.eiq")
		val writer = new FileWriter(patternsFile)
		val fileContent = '''
			package org.eclipse.viatra.cep.mqtt.cep.eiq
			
			import "http://www.eclipse.org/viatra/cep/mqtt/midl/MIDL"
			
			«FOR sensor : sensors»
				«FOR message : sensor.messages»
					«generateMessagePatterns(sensor.name, message)»
				«ENDFOR»
			«ENDFOR»
		'''
		writer.write(fileContent)
		writer.close
	}

	private def generateMessagePatterns(String sensorName, Message message) '''
		«FOR parameter : message.dataParameters»
			«FOR criterion : parameter.criteria»
				«IF (criterion.prefix == "min" || criterion.prefix == "max")»
					«generateLessThanPattern(sensorName, message.name.toFirstUpper, parameter, criterion)»
					«generateGreaterThanPattern(sensorName, message.name.toFirstUpper, parameter, criterion)»
					«generateEqualsPattern(sensorName, message.name.toFirstUpper, parameter, criterion)»
				«ELSEIF (criterion.prefix == "eq" || criterion.prefix == "neq")»				
					«generateEqualsPattern(sensorName, message.name.toFirstUpper, parameter, criterion)»
					«generateNotEqualsPattern(sensorName, message.name.toFirstUpper, parameter, criterion)»
				«ENDIF»
			«ENDFOR»
		«ENDFOR»
		«FOR parameter : message.messageParameters»
			«generateMessagePatterns(sensorName, parameter.message)»
		«ENDFOR»
	'''

	private def generateLessThanPattern(String sensorName, String messageName, DataParameter parameter,
		Criterion criterion) '''
		
		pattern «sensorName.toFirstLower»«messageName»«parameter.name.toFirstUpper»LessThan«criterion.prefix.toFirstUpper»Pattern(sensor: Sensor) {
			Sensor.name(sensor, name);
			check(name == "«sensorName»");
			Sensor.messages.dataParameters(sensor, parameter);
			«parameter.type.toFirstUpper»Parameter.value(parameter, value);
			check(value < «getCriterionValue(criterion)»);
		}
	'''

	private def generateGreaterThanPattern(String sensorName, String messageName, DataParameter parameter,
		Criterion criterion) '''
		
		pattern «sensorName.toFirstLower»«messageName»«parameter.name.toFirstUpper»GreaterThan«criterion.prefix.toFirstUpper»Pattern(sensor: Sensor) {
			Sensor.name(sensor, name);
			check(name == "«sensorName»");
			Sensor.messages.dataParameters(sensor, parameter);
			«parameter.type.toFirstUpper»Parameter.value(parameter, value);
			check(value > «getCriterionValue(criterion)»);
		}
	'''

	private def generateEqualsPattern(String sensorName, String messageName, DataParameter parameter,
		Criterion criterion) '''
		
		pattern «sensorName.toFirstLower»«messageName»«parameter.name.toFirstUpper»Equals«criterion.prefix.toFirstUpper»Pattern(sensor: Sensor) {
			Sensor.name(sensor, name);
			check(name == "«sensorName»");
			Sensor.messages.dataParameters(sensor, parameter);
			«parameter.type.toFirstUpper»Parameter.value(parameter, value);
			check(value == «getCriterionValue(criterion)»);
		}
	'''

	private def generateNotEqualsPattern(String sensorName, String messageName, DataParameter parameter,
		Criterion criterion) '''
		
		pattern «sensorName.toFirstLower»«messageName»«parameter.name.toFirstUpper»NotEquals«criterion.prefix.toFirstUpper»Pattern(sensor: Sensor) {
			Sensor.name(sensor, name);
			check(name == "«sensorName»");
			Sensor.messages.dataParameters(sensor, parameter);
			«parameter.type.toFirstUpper»Parameter.value(parameter, value);
			check(value != «getCriterionValue(criterion)»);
		}
	'''

	private def getCriterionValue(Criterion criterion) {
		if (criterion instanceof IntCriterion) {
			return criterion.value
		} else if (criterion instanceof DoubleCriterion) {
			return criterion.value
		} else if (criterion instanceof StringCriterion) {
			return criterion.value
		} else if (criterion instanceof BooleanCriterion) {
			return criterion.value
		}
	}

	private def generateRules(File cepTopPackage, EList<Sensor> sensors) {
		val veplPackage = FileUtils.createFolder(new File(cepTopPackage, "vepl"))
		val patternsFile = new File(veplPackage, "Events.vepl")
		val writer = new FileWriter(patternsFile)
		val fileContent = '''
			package org.eclipse.viatra.cep.mqtt.cep.vepl.firstLevel
			
			import-queries org.eclipse.viatra.cep.mqtt.cep.eiq.*
			
			«FOR sensor : sensors»
				«FOR message : sensor.messages»
					«generateMessageRules(sensor.name.toFirstLower, message)»
				«ENDFOR»
			«ENDFOR»
		'''
		writer.write(fileContent)
		writer.close
	}

	private def generateMessageRules(String sensorName, Message message) '''
		«FOR parameter : message.dataParameters»
			«FOR criterion : parameter.criteria»
				«IF (criterion.prefix == "min" || criterion.prefix == "max")»
					«generateLessThanEventAndRule(sensorName, message.name.toFirstUpper, parameter, criterion)»
					«generateGreaterThanEventAndRule(sensorName, message.name.toFirstUpper, parameter, criterion)»
					«generateEqualsEventAndRule(sensorName, message.name.toFirstUpper, parameter, criterion)»
				«ELSEIF (criterion.prefix == "eq" || criterion.prefix == "neq")»				
					«generateEqualsEventAndRule(sensorName, message.name.toFirstUpper, parameter, criterion)»
					«generateNotEqualsEventAndRule(sensorName, message.name.toFirstUpper, parameter, criterion)»
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