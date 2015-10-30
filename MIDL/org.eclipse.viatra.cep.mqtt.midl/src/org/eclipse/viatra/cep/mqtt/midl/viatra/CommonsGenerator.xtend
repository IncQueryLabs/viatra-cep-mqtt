package org.eclipse.viatra.cep.mqtt.midl.viatra

import java.io.File
import java.io.FileWriter
import org.eclipse.viatra.cep.mqtt.midl.utils.FileUtils

class CommonsGenerator {

	File rootFolder
	File commonsProjectFolder
	File commonsSrcFolder
	File commonsTopPackage

	new(String rootPath) {
		rootFolder = FileUtils.createFolder(new File(rootPath))
		commonsProjectFolder = FileUtils.createFolder(new File(rootFolder, "org.eclipse.viatra.cep.mqtt.commons"))
		commonsSrcFolder = FileUtils.createFolder(new File(commonsProjectFolder, "src"))
		commonsTopPackage = FileUtils.createPackage(commonsSrcFolder, "org.eclipse.viatra.cep.mqtt.commons")
	}

	public def generateCommonsProject() {
		// Generate project files
		generateBuildPropertiesFile
		generateClasspathFile
		generateManifestFile
		generateProjectFile
		generateSettingsFile
		// Generate codes
		generateLoggerUtil
		generateGeneralPublisher
		generateGeneralSubscriber
	}
	
	private def generateClasspathFile() {
		val classpathFile = FileUtils.createFile(commonsProjectFolder, ".classpath")
		val writer = new FileWriter(classpathFile)
		val fileContent = '''
			<?xml version="1.0" encoding="UTF-8"?>
			<classpath>
				<classpathentry kind="con" path="org.eclipse.jdt.launching.JRE_CONTAINER/org.eclipse.jdt.internal.debug.ui.launcher.StandardVMType/JavaSE-1.8"/>
				<classpathentry kind="con" path="org.eclipse.pde.core.requiredPlugins"/>
				<classpathentry kind="src" path="src"/>
				<classpathentry kind="output" path="bin"/>
			</classpath>
		'''
		writer.write(fileContent)
		writer.close
	}
	
	private def generateProjectFile() {
		val projectFile = FileUtils.createFile(commonsProjectFolder, ".project")
		val writer = new FileWriter(projectFile)
		val fileContent = '''
			<?xml version="1.0" encoding="UTF-8"?>
			<projectDescription>
				<name>org.eclipse.viatra.cep.mqtt.commons</name>
				<comment></comment>
				<projects>
				</projects>
				<buildSpec>
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
				</natures>
			</projectDescription>
		'''
		writer.write(fileContent)
		writer.close
	}
	
	private def generateBuildPropertiesFile() {
		val buildPropertiesFile = FileUtils.createFile(commonsProjectFolder, "build.properties")
		val writer = new FileWriter(buildPropertiesFile)
		val fileContent = '''
			source.. = src/
			output.. = bin/
			bin.includes = META-INF/,\
			               .
		'''
		writer.write(fileContent)
		writer.close
	}
	
	private def generateManifestFile() {
		val metainfFolder = FileUtils.createFolder(new File(commonsProjectFolder, "META-INF"))
		val manifestFile = FileUtils.createFile(metainfFolder, "MANIFEST.MF")
		val writer = new FileWriter(manifestFile)
		val fileContent = '''
			Manifest-Version: 1.0
			Bundle-ManifestVersion: 2
			Bundle-Name: Commons
			Bundle-SymbolicName: org.eclipse.viatra.cep.mqtt.commons
			Bundle-Version: 1.0.0.qualifier
			Bundle-RequiredExecutionEnvironment: JavaSE-1.8
			Require-Bundle: org.apache.log4j;bundle-version="1.2.15",
			 org.eclipse.paho.client.mqttv3;bundle-version="1.0.2"
			Export-Package: org.eclipse.viatra.cep.mqtt.commons.mqtt,
			 org.eclipse.viatra.cep.mqtt.commons.utils
		'''
		writer.write(fileContent)
		writer.close
	}
	
	private def generateSettingsFile() {
		val settingsFolder = FileUtils.createFolder(new File(commonsProjectFolder, ".settings"))
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

	private def generateLoggerUtil() {
		val utilsPackage = FileUtils.createFolder(new File(commonsTopPackage, "utils"))
		val subscriberFile = FileUtils.createFile(utilsPackage, "LoggerUtil.java")
		val writer = new FileWriter(subscriberFile)
		val fileContent = '''
			package org.eclipse.viatra.cep.mqtt.commons.utils;
			
			import org.apache.log4j.Logger;
			
			public class LoggerUtil {
			
				private final Logger logger;
			
				public LoggerUtil(Logger logger) {
					this.logger = logger;
				}
			
				public void error(String msg) {
					System.err.println(msg);
					logger.error(msg);
				}
			
				public void error(String msg, Throwable t) {
					System.err.println(msg);
					logger.error(msg, t);
				}
			
				public void info(String msg) {
					System.out.println(msg);
					logger.info(msg);
				}
			
				public void debug(String msg) {
					logger.debug(msg);
				}
			
			}
		'''
		writer.write(fileContent)
		writer.close
	}

	private def generateGeneralSubscriber() {
		val mqttPackage = FileUtils.createFolder(new File(commonsTopPackage, "mqtt"))
		val subscriberFile = FileUtils.createFile(mqttPackage, "Subscriber.java")
		val writer = new FileWriter(subscriberFile)
		val fileContent = '''
			package org.eclipse.viatra.cep.mqtt.commons.mqtt;
			
			import org.apache.log4j.Logger;
			import org.eclipse.paho.client.mqttv3.MqttCallback;
			import org.eclipse.paho.client.mqttv3.MqttClient;
			import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
			import org.eclipse.paho.client.mqttv3.MqttException;
			import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;
			import org.eclipse.viatra.cep.mqtt.commons.utils.LoggerUtil;
			
			public class Subscriber {
			
				protected MqttClient client;
				protected MqttConnectOptions connOpts;
				MemoryPersistence persistance = new MemoryPersistence();
			
				private static final Logger log4jLogger = Logger.getLogger(Subscriber.class);
				private static final LoggerUtil LOGGER = new LoggerUtil(log4jLogger);
			
				public Subscriber(String brokerUrl, String clientId) {
					try {
						client = new MqttClient(brokerUrl, clientId, persistance);
					} catch (MqttException e) {
						LOGGER.error("Could not create MQTTClient.", e);
					}
					connOpts = new MqttConnectOptions();
					connOpts.setCleanSession(true);
				}
			
				public void setCallback(MqttCallback callback) {
					client.setCallback(callback);
				}
			
				public void connect() {
					try {
						client.connect(connOpts);
					} catch (MqttException e) {
						LOGGER.error("Could not connect to MQTT broker.", e);
						System.exit(0);
					}
				}
			
				public void subscribe(String topic) {
					try {
						client.subscribe(topic);
					} catch (MqttException e) {
						LOGGER.error("Could not subscribe to the topic. [" + topic + "]", e);
					}
				}
			
				public void unsubscribe(String topic) {
					try {
						client.unsubscribe(topic);
					} catch (MqttException e) {
						LOGGER.error("Could not unsubscribe from the topic. [" + topic + "]", e);
					}
				}
			
				public void disconnect() {
					try {
						client.disconnect();
					} catch (MqttException e) {
						LOGGER.error("Could not disconnect from MQTT broker.", e);
					}
				}
			
			}
		'''
		writer.write(fileContent)
		writer.close
	}

	private def generateGeneralPublisher() {
		val mqttPackage = FileUtils.createFolder(new File(commonsTopPackage, "mqtt"))
		val subscriberFile = FileUtils.createFile(mqttPackage, "Publisher.java")
		val writer = new FileWriter(subscriberFile)
		val fileContent = '''
			package org.eclipse.viatra.cep.mqtt.commons.mqtt;
			
			import java.io.UnsupportedEncodingException;
			
			import org.apache.log4j.Logger;
			import org.eclipse.paho.client.mqttv3.MqttClient;
			import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
			import org.eclipse.paho.client.mqttv3.MqttException;
			import org.eclipse.paho.client.mqttv3.MqttMessage;
			import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;
			import org.eclipse.viatra.cep.mqtt.commons.utils.LoggerUtil;
			
			public class Publisher {
			
				protected MqttClient client;
				protected MqttConnectOptions connOpts;
				MemoryPersistence persistance = new MemoryPersistence();
			
				private static final Logger log4jLogger = Logger.getLogger(Publisher.class);
				private static final LoggerUtil LOGGER = new LoggerUtil(log4jLogger);
			
				public Publisher(String brokerUrl, String clientId) {
					try {
						client = new MqttClient(brokerUrl, clientId, persistance);
					} catch (MqttException e) {
						LOGGER.error("Could not create MQTTClient.", e);
					}
					connOpts = new MqttConnectOptions();
					connOpts.setCleanSession(true);
				}
			
				public void connect() {
					try {
						client.connect(connOpts);
					} catch (MqttException e) {
						LOGGER.error("Could not connect to MQTT broker.", e);
						System.exit(0);
					}
				}
			
					public void publish(String topic, String payload) {
					  	try {
						publish(topic, payload.getBytes("UTF-8"));
					} catch (UnsupportedEncodingException e) {
						LOGGER.error("Could not encode message. [" + payload + "]", e);
					}
					  }
			
				public void publish(String topic, byte[] payload) {
					MqttMessage message = new MqttMessage(payload);
					      message.setQos(0);
					      message.setRetained(false);
					try {
						client.publish(topic, message);
					} catch (MqttException e) {
						LOGGER.error("Could not publish MQTT message.", e);
					}
				}
			
				public void disconnect() {
					try {
						client.disconnect();
					} catch (MqttException e) {
						LOGGER.error("Could not disconnect from MQTT broker.", e);
					}
				}
			
			}
		'''
		writer.write(fileContent)
		writer.close
	}

}