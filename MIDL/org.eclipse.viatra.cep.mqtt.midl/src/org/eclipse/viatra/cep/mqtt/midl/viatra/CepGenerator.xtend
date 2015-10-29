package org.eclipse.viatra.cep.mqtt.midl.viatra

import java.io.File
import java.io.FileWriter
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.common.util.URI
import org.eclipse.viatra.cep.mqtt.midl.mIDL.MqttSetup
import org.eclipse.viatra.cep.mqtt.midl.mIDL.Sensor
import org.eclipse.viatra.cep.mqtt.midl.utils.FileUtils

class CepGenerator {
	
	File rootFolder
	File cepProjectFolder
	File cepSrcFolder
	File cepTopPackage
	URI uri
	
	new(String rootPath, URI uri) {
		rootFolder = FileUtils.createFolder(new File(rootPath))
		cepProjectFolder = FileUtils.createFolder(new File(rootFolder, "org.eclipse.viatra.cep.mqtt.cep"))
		cepSrcFolder = FileUtils.createFolder(new File(cepProjectFolder, "src"))
		cepTopPackage = FileUtils.createPackage(cepSrcFolder, "org.eclipse.viatra.cep.mqtt.cep")
		this.uri = uri
	}
	
	public def generateCepProject(EList<Sensor> sensors, MqttSetup setup){
		val patternGenerator = new PatternGenerator
		patternGenerator.generatePatternsAndRules(cepTopPackage, sensors)
		generateCepApplication(sensors, setup)
		generateCallback(sensors)
		generateBuildPropertiesFile
		generateClasspathFile
		generateJdtSettingFile
		generateManifestFile
		generatePdeSettingFile
		generatePluginXmlFile
		generateProjectFile
	}
	
	private def generateClasspathFile() {
		val classpathFile = FileUtils.createFile(cepProjectFolder, ".classpath")
		val writer = new FileWriter(classpathFile)
		val fileContent = '''
			<?xml version="1.0" encoding="UTF-8"?>
			<classpath>
				<classpathentry kind="con" path="org.eclipse.jdt.launching.JRE_CONTAINER/org.eclipse.jdt.internal.debug.ui.launcher.StandardVMType/JavaSE-1.8"/>
				<classpathentry kind="con" path="org.eclipse.pde.core.requiredPlugins"/>
				<classpathentry kind="src" path="src/"/>
				<classpathentry kind="src" path="src-gen/"/>
				<classpathentry kind="output" path="bin"/>
			</classpath>
		'''
		writer.write(fileContent)
		writer.close
	}
	
	private def generateProjectFile() {
		val projectFile = FileUtils.createFile(cepProjectFolder, ".project")
		val writer = new FileWriter(projectFile)
		val fileContent = '''
			<?xml version="1.0" encoding="UTF-8"?>
			<projectDescription>
				<name>org.eclipse.viatra.cep.mqtt.cep</name>
				<comment></comment>
				<projects>
				</projects>
				<buildSpec>
					<buildCommand>
						<name>org.eclipse.incquery.tooling.core.projectbuilder</name>
						<arguments>
						</arguments>
					</buildCommand>
					<buildCommand>
						<name>org.eclipse.xtext.ui.shared.xtextBuilder</name>
						<arguments>
						</arguments>
					</buildCommand>
					<buildCommand>
						<name>org.eclipse.jdt.core.javabuilder</name>
						<arguments>
						</arguments>
					</buildCommand>
					<buildCommand>
						<name>org.eclipse.pde.ManifestBuilder</name>
						<arguments>
						</arguments>
					</buildCommand>
					<buildCommand>
						<name>org.eclipse.pde.SchemaBuilder</name>
						<arguments>
						</arguments>
					</buildCommand>
				</buildSpec>
				<natures>
					<nature>org.eclipse.pde.PluginNature</nature>
					<nature>org.eclipse.jdt.core.javanature</nature>
					<nature>org.eclipse.xtext.ui.shared.xtextNature</nature>
					<nature>org.eclipse.incquery.projectnature</nature>
				</natures>
			</projectDescription>
		'''
		writer.write(fileContent)
		writer.close
	}
	
	private def generatePluginXmlFile() {
		val pluginFile = FileUtils.createFile(cepProjectFolder, "plugin.xml")
		val writer = new FileWriter(pluginFile)
		val fileContent = '''
			<?xml version="1.0" encoding="UTF-8"?><plugin>
			  <extension id="org.eclipse.viatra.cep.mqtt.cep.eiq.Patterns" point="org.eclipse.incquery.runtime.queryspecification">
			    <group group="org.eclipse.incquery.runtime.extensibility.SingletonExtensionFactory:org.eclipse.viatra.cep.mqtt.cep.eiq.Patterns" id="org.eclipse.viatra.cep.mqtt.cep.eiq.Patterns"/>
			  </extension>
			</plugin>
		'''
		writer.write(fileContent)
		writer.close
	}
	
	private def generateBuildPropertiesFile() {
		val buildFile = FileUtils.createFile(cepProjectFolder, "build.properties")
		val writer = new FileWriter(buildFile)
		val fileContent = '''
			bin.includes = META-INF/,\
			               .,\
			               plugin.xml
			source.. = src/,\
			           src-gen/
			output.. = bin/
		'''
		writer.write(fileContent)
		writer.close
	}
	
	private def generateManifestFile() {
		val metainfFolder = FileUtils.createFolder(new File(cepProjectFolder, "META-INF"))
		val manifestFile = FileUtils.createFile(metainfFolder, "MANIFEST.MF")
		val writer = new FileWriter(manifestFile)
		val fileContent = '''
			Manifest-Version: 1.0
			Bundle-ManifestVersion: 2
			Bundle-Name: Cep
			Bundle-SymbolicName: org.eclipse.viatra.cep.mqtt.cep;singleton:=true
			Bundle-Version: 1.0.0.qualifier
			Export-Package: org.eclipse.viatra.cep.mqtt.cep.eiq,
			 org.eclipse.viatra.cep.mqtt.cep.eiq.util,
			 org.eclipse.viatra.cep.mqtt.cep.vepl.firstLevel,
			 org.eclipse.viatra.cep.mqtt.cep.vepl.firstLevel.events.queryresult,
			 org.eclipse.viatra.cep.mqtt.cep.vepl.firstLevel.jobs,
			 org.eclipse.viatra.cep.mqtt.cep.vepl.firstLevel.mapping,
			 org.eclipse.viatra.cep.mqtt.cep.vepl.firstLevel.patterns.atomic.queryresult,
			 org.eclipse.viatra.cep.mqtt.cep.vepl.firstLevel.rules
			Require-Bundle: org.eclipse.emf.ecore,
			 org.eclipse.incquery.runtime,
			 org.eclipse.xtext.xbase.lib,
			 org.eclipse.viatra.cep.core;bundle-version="0.8.0",
			 com.eclipsesource.json;bundle-version="1.0.0",
			 org.eclipse.emf.mwe.utils;bundle-version="1.3.20",
			 org.eclipse.viatra.cep.mqtt.commons;bundle-version="1.0.0",
			 org.eclipse.viatra.cep.mqtt.midl;bundle-version="1.0.0",
			 org.eclipse.xtext;bundle-version="2.9.0",
			 org.eclipse.paho.client.mqttv3;bundle-version="1.0.2"
			Bundle-RequiredExecutionEnvironment: JavaSE-1.8
			Import-Package: org.apache.log4j
		'''
		writer.write(fileContent)
		writer.close
	}
	
	private def generateJdtSettingFile() {
		val settingsFolder = FileUtils.createFolder(new File(cepProjectFolder, ".settings"))
		val prefsFile = FileUtils.createFile(settingsFolder, "org.eclipse.jdt.core.prefs")
		val writer = new FileWriter(prefsFile)
		val fileContent = '''
			eclipse.preferences.version=1
			org.eclipse.jdt.core.compiler.codegen.inlineJsrBytecode=enabled
			org.eclipse.jdt.core.compiler.codegen.targetPlatform=1.8
			org.eclipse.jdt.core.compiler.compliance=1.8
			org.eclipse.jdt.core.compiler.problem.assertIdentifier=error
			org.eclipse.jdt.core.compiler.problem.enumIdentifier=error
			org.eclipse.jdt.core.compiler.source=1.8
		'''
		writer.write(fileContent)
		writer.close
	}
	
	private def generatePdeSettingFile() {
		val settingsFolder = FileUtils.createFolder(new File(cepProjectFolder, ".settings"))
		val prefsFile = FileUtils.createFile(settingsFolder, "org.eclipse.pde.core.prefs")
		val writer = new FileWriter(prefsFile)
		val fileContent = '''
			eclipse.preferences.version=1
			pluginProject.equinox=false
			resolve.requirebundle=false
		'''
		writer.write(fileContent)
		writer.close
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
					resource = resourceSet.getResource(URI.createURI("«uri.toString»"), true);
			
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