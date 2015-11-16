package org.eclipse.viatra.cep.mqtt.midl.viatra

import java.io.ByteArrayInputStream
import org.eclipse.core.resources.IFolder
import org.eclipse.emf.common.util.EList
import org.eclipse.viatra.cep.mqtt.midl.mIDL.BooleanCriterion
import org.eclipse.viatra.cep.mqtt.midl.mIDL.Criterion
import org.eclipse.viatra.cep.mqtt.midl.mIDL.DataParameter
import org.eclipse.viatra.cep.mqtt.midl.mIDL.DoubleCriterion
import org.eclipse.viatra.cep.mqtt.midl.mIDL.IntCriterion
import org.eclipse.viatra.cep.mqtt.midl.mIDL.Payload
import org.eclipse.viatra.cep.mqtt.midl.mIDL.Sensor
import org.eclipse.viatra.cep.mqtt.midl.mIDL.StringCriterion
import org.eclipse.emf.common.util.URI

class PatternGenerator {
	
	URI uri

	public  def generatePatternsAndRules(IFolder topPackage, EList<Sensor> sensors, URI uri) {
		this.uri = uri
		generatePatterns(topPackage, sensors)
		generateRules(topPackage, sensors)
	}

	private def generatePatterns(IFolder topPackage, EList<Sensor> sensors) {
		val eiqPackage = topPackage.getFolder("eiq")
		if (!eiqPackage.exists)
			eiqPackage.create(true, true, null)
		val patternsFile = eiqPackage.getFile("Patterns.eiq")
		val fileContent = '''
			package «uri.segments.get(1)».eiq
			
			import "http://www.eclipse.org/viatra/cep/mqtt/midl/MIDL"
			
			«FOR sensor : sensors»
				«generatePayloadPatterns(sensor.name, sensor.lastReceivedPayload)»
			«ENDFOR»
		'''
		if (patternsFile.exists)
			patternsFile.delete(true, null)
		val source = new ByteArrayInputStream(fileContent.bytes)
		patternsFile.create(source, true, null)
	}

	private def generatePayloadPatterns(String sensorName, Payload payload) '''
		«FOR parameter : payload.dataParameters»
			«FOR criterion : parameter.criteria»
				«IF (criterion.prefix == "min" || criterion.prefix == "max")»
					«generateLessThanPattern(sensorName, parameter, criterion)»
					«generateGreaterThanPattern(sensorName, parameter, criterion)»
					«generateEqualsPattern(sensorName, parameter, criterion)»
				«ELSEIF (criterion.prefix == "eq" || criterion.prefix == "neq")»				
					«generateEqualsPattern(sensorName, parameter, criterion)»
					«generateNotEqualsPattern(sensorName, parameter, criterion)»
				«ENDIF»
			«ENDFOR»
		«ENDFOR»
	'''

	private def generateLessThanPattern(String sensorName, DataParameter parameter,
		Criterion criterion) '''
		
		/*
		 * This pattern returns with a sensor, what has the name "«sensorName»"
		 * and one of it's parameter value is less than «getCriterionValue(criterion)».
		 */
		pattern «sensorName.toFirstLower»«parameter.name.toFirstUpper»LessThan«criterion.prefix.toFirstUpper»(sensor: Sensor) {
			Sensor.name(sensor, "«sensorName»");
			Sensor.lastReceivedPayload.dataParameters(sensor, parameter);
			«parameter.type.toFirstUpper»Parameter.value(parameter, value);
			check(value < «getCriterionValue(criterion)»);
		}
	'''

	private def generateGreaterThanPattern(String sensorName, DataParameter parameter,
		Criterion criterion) '''
		
		/*
		 * This pattern returns with a sensor, what has the name "«sensorName»"
		 * and one of it's parameter value is greater than «getCriterionValue(criterion)».
		 */
		pattern «sensorName.toFirstLower»«parameter.name.toFirstUpper»GreaterThan«criterion.prefix.toFirstUpper»(sensor: Sensor) {
			Sensor.name(sensor, "«sensorName»");
			Sensor.lastReceivedPayload.dataParameters(sensor, parameter);
			«parameter.type.toFirstUpper»Parameter.value(parameter, value);
			check(value > «getCriterionValue(criterion)»);
		}
	'''

	private def generateEqualsPattern(String sensorName, DataParameter parameter,
		Criterion criterion) '''
		
		/*
		 * This pattern returns with a sensor, what has the name "«sensorName»"
		 * and one of it's parameter value is equals with «getCriterionValue(criterion)».
		 */
		«IF criterion.prefix.equals("eq") || criterion.prefix.equals("neq")»
			pattern «sensorName.toFirstLower»«parameter.name.toFirstUpper»Equals(sensor: Sensor) {
		«ELSE»
			pattern «sensorName.toFirstLower»«parameter.name.toFirstUpper»«criterion.prefix.toFirstUpper»Equals(sensor: Sensor) {
		«ENDIF»
			Sensor.name(sensor, "«sensorName»");
			Sensor.lastReceivedPayload.dataParameters(sensor, parameter);
			«IF parameter.type.equals("string")»
				«parameter.type.toFirstUpper»Parameter.value(parameter, "«getCriterionValue(criterion)»");
			«ELSE»
				«parameter.type.toFirstUpper»Parameter.value(parameter, «getCriterionValue(criterion)»);
			«ENDIF»
		}
	'''

	private def generateNotEqualsPattern(String sensorName, DataParameter parameter,
		Criterion criterion) '''
		
		/*
		 * This pattern returns with a sensor, what has the name "«sensorName»"
		 * and one of it's parameter value is not equals with «getCriterionValue(criterion)».
		 */
		«IF criterion.prefix.equals("eq") || criterion.prefix.equals("neq")»
			pattern «sensorName.toFirstLower»«parameter.name.toFirstUpper»NotEquals(sensor: Sensor) {
		«ELSE»
			pattern «sensorName.toFirstLower»«parameter.name.toFirstUpper»«criterion.prefix.toFirstUpper»NotEquals(sensor: Sensor) {
		«ENDIF»
			Sensor.name(sensor, "«sensorName»");
			Sensor.lastReceivedPayload.dataParameters(sensor, parameter);
			«parameter.type.toFirstUpper»Parameter.value(parameter, value);
			«IF parameter.type.equals("string")»
				check(value != "«getCriterionValue(criterion)»");
			«ELSE»
				check(value != «getCriterionValue(criterion)»);
			«ENDIF»
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

	private def generateRules(IFolder cepTopPackage, EList<Sensor> sensors) {
		val veplPackage = cepTopPackage.getFolder("vepl")
		if (!veplPackage.exists)
			veplPackage.create(true, true, null)
		val veplFile = veplPackage.getFile("Events.vepl")
		val fileContent = '''
			package «uri.segments.get(1)».vepl.firstLevel
			
			import-queries «uri.segments.get(1)».eiq.*
			
			«FOR sensor : sensors»
				«generatePayloadRules(sensor.name.toFirstLower, sensor.lastReceivedPayload)»
			«ENDFOR»
		'''
		if (veplFile.exists)
			veplFile.delete(true, null)
		val source = new ByteArrayInputStream(fileContent.bytes)
		veplFile.create(source, true, null)
	}

	private def generatePayloadRules(String sensorName, Payload payload) '''
		«FOR parameter : payload.dataParameters»
			«FOR criterion : parameter.criteria»
				«IF (criterion.prefix == "min" || criterion.prefix == "max")»
					«generateLessThanEventAndRule(sensorName, payload.name.toFirstUpper, parameter, criterion)»
					«generateGreaterThanEventAndRule(sensorName, payload.name.toFirstUpper, parameter, criterion)»
					«generateEqualsEventAndRule(sensorName, payload.name.toFirstUpper, parameter, criterion)»
				«ELSEIF (criterion.prefix == "eq" || criterion.prefix == "neq")»				
					«generateEqualsEventAndRule(sensorName, payload.name.toFirstUpper, parameter, criterion)»
					«generateNotEqualsEventAndRule(sensorName, payload.name.toFirstUpper, parameter, criterion)»
				«ENDIF»
			«ENDFOR»
		«ENDFOR»
	'''

	private def generateLessThanEventAndRule(String sensorName, String messageName, DataParameter parameter,
		Criterion criterion) '''
		
		/* 
		 * This event execute, if the «sensorName»«parameter.name.toFirstUpper»LessThan«criterion.prefix.toFirstUpper»
		 * pattern has return value.
		 */
		queryEvent «sensorName»«parameter.name.toFirstUpper»LessThan«criterion.prefix.toFirstUpper»Event() as
			«sensorName»«parameter.name.toFirstUpper»LessThan«criterion.prefix.toFirstUpper»(_) found
		
		/* 
		 * This rule activate, when the «sensorName»«parameter.name.toFirstUpper»LessThan«criterion.prefix.toFirstUpper»Event
		 * event has been executed.
		 * The rule write a simple message to console.
		 */
		rule «sensorName»«parameter.name.toFirstUpper»LessThan«criterion.prefix.toFirstUpper»Rule on «sensorName»«parameter.name.toFirstUpper»LessThan«criterion.prefix.toFirstUpper»Event {
			println("«sensorName.toFirstUpper» «messageName» «parameter.name» less than rule activated!")
		}
	'''

	private def generateGreaterThanEventAndRule(String sensorName, String messageName, DataParameter parameter,
		Criterion criterion) '''
		
		/* 
		 * This event execute, if the «sensorName»«parameter.name.toFirstUpper»GreaterThan«criterion.prefix.toFirstUpper»
		 * pattern has return value.
		 */
		queryEvent «sensorName»«parameter.name.toFirstUpper»GreaterThan«criterion.prefix.toFirstUpper»Event() as
			«sensorName»«parameter.name.toFirstUpper»GreaterThan«criterion.prefix.toFirstUpper»(_) found
		
		/* 
		 * This rule activate, when the «sensorName»«parameter.name.toFirstUpper»GreaterThan«criterion.prefix.toFirstUpper»Event
		 * event has been executed.
		 * The rule write a simple message to console.
		 */
		rule «sensorName»«parameter.name.toFirstUpper»GreaterThan«criterion.prefix.toFirstUpper»Rule on «sensorName»«parameter.name.toFirstUpper»GreaterThan«criterion.prefix.toFirstUpper»Event {
			println("«sensorName.toFirstUpper» «messageName» «parameter.name» greater than rule activated!")
		}
	'''

	private def generateEqualsEventAndRule(String sensorName, String messageName, DataParameter parameter,
		Criterion criterion) '''
		
		«IF criterion.prefix.equals("eq") || criterion.prefix.equals("neq")»
			/* 
			 * This event execute, if the «sensorName»«parameter.name.toFirstUpper»Equals
			 * pattern has return value.
			 */
			queryEvent «sensorName»«parameter.name.toFirstUpper»EqualsEvent() as
				«sensorName»«parameter.name.toFirstUpper»Equals(_) found
			
			/* 
			 * This rule activate, when the «sensorName»«parameter.name.toFirstUpper»EqualsEvent
			 * event has been executed.
			 * The rule write a simple message to console.
			 */
			rule «sensorName»«parameter.name.toFirstUpper»EqualsRule on «sensorName»«parameter.name.toFirstUpper»EqualsEvent {
				println("«sensorName.toFirstUpper» «messageName» «parameter.name» equal rule activated!")
			}
		«ELSE»
			/* 
			 * This event execute, if the «sensorName»«parameter.name.toFirstUpper»«criterion.prefix.toFirstUpper»Equals
			 * pattern has return value.
			 */
			queryEvent «sensorName»«parameter.name.toFirstUpper»«criterion.prefix.toFirstUpper»EqualsEvent() as
				«sensorName»«parameter.name.toFirstUpper»«criterion.prefix.toFirstUpper»Equals(_) found
			
			/* 
			 * This rule activate, when the «sensorName»«parameter.name.toFirstUpper»«criterion.prefix.toFirstUpper»EqualsEvent
			 * event has been executed.
			 * The rule write a simple message to console.
			 */
			rule «sensorName»«parameter.name.toFirstUpper»«criterion.prefix.toFirstUpper»EqualsRule on «sensorName»«parameter.name.toFirstUpper»«criterion.prefix.toFirstUpper»EqualsEvent {
				println("«sensorName.toFirstUpper» «messageName» «parameter.name» «criterion.prefix» equal rule activated!")
			}
		«ENDIF»
	'''

	private def generateNotEqualsEventAndRule(String sensorName, String messageName, DataParameter parameter,
		Criterion criterion) '''
		
		«IF criterion.prefix.equals("eq") || criterion.prefix.equals("neq")»
			/* 
			 * This event execute, if the «sensorName»«parameter.name.toFirstUpper»NotEquals
			 * pattern has return value.
			 */
			queryEvent «sensorName»«parameter.name.toFirstUpper»NotEqualsEvent() as
				«sensorName»«parameter.name.toFirstUpper»NotEquals(_) found
			
			/* 
			 * This rule activate, when the «sensorName»«parameter.name.toFirstUpper»NotEqualsEvent
			 * event has been executed.
			 * The rule write a simple message to console.
			 */
			rule «sensorName»«parameter.name.toFirstUpper»NotEqualsRule on «sensorName»«parameter.name.toFirstUpper»NotEqualsEvent {
				println("«sensorName.toFirstUpper» «messageName» «parameter.name» not equal rule activated!")
			}
		«ELSE»
			/* 
			 * This event execute, if the «sensorName»«parameter.name.toFirstUpper»«criterion.prefix.toFirstUpper»NotEquals
			 * pattern has return value.
			 */
			queryEvent «sensorName»«parameter.name.toFirstUpper»«criterion.prefix.toFirstUpper»NotEqualsEvent() as
				«sensorName»«parameter.name.toFirstUpper»«criterion.prefix.toFirstUpper»NotEquals(_) found
			
			/* 
			 * This rule activate, when the «sensorName»«parameter.name.toFirstUpper»«criterion.prefix.toFirstUpper»NotEqualsEvent
			 * event has been executed.
			 * The rule write a simple message to console.
			 */
			rule «sensorName»«parameter.name.toFirstUpper»«criterion.prefix.toFirstUpper»NotEqualsRule on «sensorName»«parameter.name.toFirstUpper»«criterion.prefix.toFirstUpper»NotEqualsEvent {
				println("«sensorName.toFirstUpper» «messageName» «parameter.name» «criterion.prefix» not equal rule activated!")
			}
		«ENDIF»
	'''

}