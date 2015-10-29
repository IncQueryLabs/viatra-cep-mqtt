package org.eclipse.viatra.cep.mqtt.midl.viatra

import java.io.File
import java.io.FileWriter
import org.eclipse.emf.common.util.EList
import org.eclipse.viatra.cep.mqtt.midl.mIDL.Sensor
import org.eclipse.viatra.cep.mqtt.midl.utils.FileUtils
import org.eclipse.viatra.cep.mqtt.midl.mIDL.MqttSetup

class CepGenerator {
	
	File rootFolder
	File cepProjectFolder
	File cepSrcFolder
	File cepTopPackage
	
	new(String rootPath) {
		rootFolder = FileUtils.createFolder(new File(rootPath))
		cepProjectFolder = FileUtils.createFolder(new File(rootFolder, "org.eclipse.viatra.cep.mqtt.cep"))
		cepSrcFolder = FileUtils.createFolder(new File(cepProjectFolder, "src"))
		cepTopPackage = FileUtils.createPackage(cepSrcFolder, "org.eclipse.viatra.cep.mqtt.cep")
	}
	
	public def generateCepProject(EList<Sensor> sensors, MqttSetup setup){
		val patternGenerator = new PatternGenerator
		patternGenerator.generatePatternsAndRules(cepTopPackage, sensors)
		generateCepApplication(sensors, setup)
		generateCallback(sensors)
	}
	
	private def generateCepApplication(EList<Sensor> sensors, MqttSetup setup) {
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
			import org.eclipse.viatra.cep.mqtt.cep.mqtt.Callback;
			import org.eclipse.viatra.cep.mqtt.cep.vepl.firstLevel.CepFactory;
			import org.eclipse.viatra.cep.mqtt.cep.vepl.firstLevel.mapping.QueryEngine2ViatraCep;
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
					subscriber = new Subscriber("«setup.brokerUrl»", "CEP_SUBSCRIBER");
					subscriber.setCallback(callback);
					subscriber.connect();
					«FOR sensor:sensors»
					subscriber.subscribe("«sensor.name»");
					«ENDFOR»
			
					running = true;
				}
			
				public void run() {
					mapping = QueryEngine2ViatraCep.register(resourceSet, eventStream);
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
	
	private def generateCallback(EList<Sensor> sensors) {
		val mqttPackage = FileUtils.createFolder(new File(cepTopPackage, "mqtt"))
		val subscriberFile = FileUtils.createFile(mqttPackage, "Callback.java")
		val writer = new FileWriter(subscriberFile)
		val fileContent = '''
			package org.eclipse.viatra.cep.mqtt.cep.mqtt;
			
			import org.apache.log4j.Logger;
			import org.eclipse.emf.ecore.resource.Resource;
			import org.eclipse.paho.client.mqttv3.IMqttDeliveryToken;
			import org.eclipse.paho.client.mqttv3.MqttCallback;
			import org.eclipse.paho.client.mqttv3.MqttMessage;
			import org.eclipse.viatra.cep.mqtt.commons.utils.LoggerUtil;
			import org.eclipse.viatra.cep.mqtt.midl.mIDL.BooleanParameter;
			import org.eclipse.viatra.cep.mqtt.midl.mIDL.DataParameter;
			import org.eclipse.viatra.cep.mqtt.midl.mIDL.DoubleParameter;
			import org.eclipse.viatra.cep.mqtt.midl.mIDL.Machine;
			import org.eclipse.viatra.cep.mqtt.midl.mIDL.Message;
			import org.eclipse.viatra.cep.mqtt.midl.mIDL.Sensor;
			
			import com.eclipsesource.json.JsonObject;
			
			public class Callback implements MqttCallback {
			
				private static final Logger log4jLogger = Logger.getLogger(Callback.class);
				private static final LoggerUtil LOGGER = new LoggerUtil(log4jLogger);
			
				Resource resource;
				
				Machine machine;
				«FOR sensor : sensors»
					Sensor «sensor.name»;
					«FOR message:sensor.messages»
						Message «message.name»;
						«FOR parameter:message.dataParameters»
							«parameter.type.toFirstUpper»Parameter «parameter.name»;
						«ENDFOR»
					«ENDFOR»
				«ENDFOR»
			
				public Callback(Resource resource) {
					this.resource = resource;
					getDataFromModel();
				}
			
				@Override
				public void connectionLost(Throwable t) {
					LOGGER.error("The connection lost.", t);
				}
			
				@Override
				public void deliveryComplete(IMqttDeliveryToken token) {
					LOGGER.info("The delivery completed.");
				}
			
				@Override
				public void messageArrived(String topic, MqttMessage message) {
					String msg = new String(message.getPayload());
					JsonObject sensor = JsonObject.readFrom(msg);
					«FOR sensor : sensors»
						if (topic.equals("«sensor.name»")) {
							«FOR message:sensor.messages»
								«FOR parameter:message.dataParameters»
									«parameter.name».setValue(sensor.get("«message.name»").asObject().get("«parameter.name»").as«parameter.type.toFirstUpper»());
								«ENDFOR»
							«ENDFOR»
						}
						
					«ENDFOR»
				}
			
				private void getDataFromModel() {
					machine = (Machine) resource.getContents().get(0);
					
					for (Sensor sensor : machine.getSensors()) {
						«FOR sensor : sensors»
							if (sensor.getName().equals("«sensor.name»")) {
								«sensor.name» = sensor;
								for (Message message : sensor.getMessages()) {
									«FOR message:sensor.messages»
										if (message.getName().equals("«message.name»")) {
											«message.name» = message;
											for (DataParameter parameter : message.getDataParameters()) {
												«FOR parameter:message.dataParameters»
													if (parameter.getName().equals("«parameter.name»")) {
														«parameter.name» = («parameter.type.toFirstUpper»Parameter) parameter;
													}
												«ENDFOR»
											}
										}
									«ENDFOR»
								}
							}
							
						«ENDFOR»
					}
				}
			
			}
		'''
		writer.write(fileContent)
		writer.close
	}
	
}