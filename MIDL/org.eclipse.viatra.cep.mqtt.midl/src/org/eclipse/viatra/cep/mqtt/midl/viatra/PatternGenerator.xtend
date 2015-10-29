package org.eclipse.viatra.cep.mqtt.midl.viatra

import java.io.File
import java.io.FileWriter
import org.eclipse.viatra.cep.mqtt.midl.mIDL.BooleanCriterion
import org.eclipse.viatra.cep.mqtt.midl.mIDL.Criterion
import org.eclipse.viatra.cep.mqtt.midl.mIDL.DataParameter
import org.eclipse.viatra.cep.mqtt.midl.mIDL.DoubleCriterion
import org.eclipse.viatra.cep.mqtt.midl.mIDL.IntCriterion
import org.eclipse.viatra.cep.mqtt.midl.mIDL.Message
import org.eclipse.viatra.cep.mqtt.midl.mIDL.Sensor
import org.eclipse.viatra.cep.mqtt.midl.mIDL.StringCriterion
import org.eclipse.viatra.cep.mqtt.midl.utils.FileUtils
import org.eclipse.emf.common.util.EList

class PatternGenerator {

	File rootFolder;
	File cepProjectFolder;
	File cepSrcFolder;
	File cepTopPackage;

	new(String rootPath) {
		rootFolder = FileUtils.createFolder(new File(rootPath))
		cepProjectFolder = FileUtils.createFolder(new File(rootFolder, "org.eclipse.viatra.cep.mqtt.cep"))
		cepSrcFolder = FileUtils.createFolder(new File(cepProjectFolder, "src"))
		cepTopPackage = FileUtils.createPackage(cepSrcFolder, "org.eclipse.viatra.cep.mqtt.cep")
	}

	public def generateDeafultFiles() {
		generateDefaultEiqFile
		generateDefaultVeplFile
	}

	public def generatePatterns(Sensor sensor) {
		createPatterns(sensor)
		createViatraRules(sensor)
	}

	private def generateDefaultEiqFile() {
		val queriesPackage = FileUtils.createFolder(new File(cepTopPackage, "queries"))
		val patternsFile = new File(queriesPackage, "Patterns.eiq")
		val writer = new FileWriter(patternsFile)
		val fileContent = '''
			package org.eclipse.viatra.cep.mqtt.cep.queries
			
			import "http://www.eclipse.org/viatra/cep/mqtt/midl/MIDL"
		'''
		writer.write(fileContent)
		writer.close
	}

	private def generateDefaultVeplFile() {
		val patternsFile = new File(cepTopPackage, "Events.vepl")
		val writer = new FileWriter(patternsFile)
		val fileContent = '''
			package org.eclipse.viatra.cep.mqtt.cep.firstLevel
			
			import-queries org.eclipse.viatra.cep.mqtt.cep.queries.*
		'''
		writer.write(fileContent)
		writer.close
	}
	
	public def generateCepApplication(EList<Sensor> sensors) {
		val patternsFile = new File(cepTopPackage, "CepApplication.java")
		val writer = new FileWriter(patternsFile)
		val fileContent = '''
			package org.eclipse.viatra.cep.mqtt.cep;
			
			import org.apache.log4j.Logger;
			import org.eclipse.emf.common.util.URI;
			import org.eclipse.emf.ecore.resource.Resource;
			import org.eclipse.emf.mwe.utils.StandaloneSetup;
			import org.eclipse.viatra.cep.core.api.engine.CEPEngine;
			import org.eclipse.viatra.cep.core.metamodels.automaton.EventContext;
			import org.eclipse.viatra.cep.core.streams.EventStream;
			import org.eclipse.viatra.cep.mqtt.cep.firstLevel.CepFactory;
			import org.eclipse.viatra.cep.mqtt.cep.firstLevel.mapping.QueryEngine2ViatraCep;
			import org.eclipse.viatra.cep.mqtt.commons.mqtt.Callback;
			import org.eclipse.viatra.cep.mqtt.commons.mqtt.Subscriber;
			import org.eclipse.viatra.cep.mqtt.commons.utils.LoggerUtil;
			import org.eclipse.viatra.cep.mqtt.midl.MIDLStandaloneSetup;
			import org.eclipse.xtext.resource.XtextResourceSet;
			
			import com.google.inject.Injector;
			
			public class CepApplication {
			
				private static final Logger log4jLogger = Logger.getLogger(CepApplication.class);
				private static final LoggerUtil LOGGER = new LoggerUtil(log4jLogger);
			
				private CEPEngine engine;
				private QueryEngine2ViatraCep mapping;
				public EventStream eventStream;
				public CepFactory cepFactory;
			
				Subscriber subscriber;
				Callback callback;
			
				protected Resource resource;
				protected XtextResourceSet resourceSet;
			
				boolean running = false;
			
				public CepApplication() {
					engine = CEPEngine.newEngine().eventContext(EventContext.STRICT_IMMEDIATE)
							.rules(CepFactory.getInstance().allRules()).prepare();
					eventStream = engine.getStreamManager().newEventStream();
			
					new StandaloneSetup().setPlatformUri("../");
					Injector injector = new MIDLStandaloneSetup().createInjectorAndDoEMFRegistration();
					resourceSet = injector.getInstance(XtextResourceSet.class);
					resource = resourceSet.getResource(URI.createURI("platform:/resource/sample/src/sample.midl"), true);
			
					callback = new Callback(resource);
					subscriber = new Subscriber("tcp://127.0.0.10:9876", "CEP_SUBSCRIBER");
					subscriber.setCallback(callback);
					subscriber.connect();
					«FOR sensor:sensors»
					subscriber.subscribe("«sensor.name»");
					«ENDFOR»
			
					mapping = QueryEngine2ViatraCep.register(resourceSet, eventStream);
			
					running = true;
				}
			
				public void run() {
					while (running) {
			
					}
					mapping.dispose();
					subscriber.disconnect();
				}
			
			}
		'''
		writer.write(fileContent)
		writer.close
	}

	private def createPatterns(Sensor sensor) {
		val queriesPackage = FileUtils.createFolder(new File(cepTopPackage, "queries"))
		val patternsFile = new File(queriesPackage, "Patterns.eiq")
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

	private def createViatraRules(Sensor sensor) {
		val patternsFile = new File(cepTopPackage, "Events.vepl")
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