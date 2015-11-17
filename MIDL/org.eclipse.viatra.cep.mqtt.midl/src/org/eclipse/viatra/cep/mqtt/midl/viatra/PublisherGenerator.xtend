package org.eclipse.viatra.cep.mqtt.midl.viatra

import org.eclipse.core.resources.IFolder
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.emf.common.util.URI
import org.eclipse.viatra.cep.mqtt.midl.utils.FileUtils
import java.io.ByteArrayInputStream
import org.eclipse.emf.common.util.EList
import org.eclipse.viatra.cep.mqtt.midl.mIDL.Sensor

class PublisherGenerator {
	
	IProject project
	IFolder src
	IFolder topPackage
	String projectName
	
	new (String rootPath, URI uri) {
		this.projectName = uri.segments.get(1) + ".publisher"
		val workspace = ResourcesPlugin.workspace.root
		project = workspace.getProject(projectName)
		if (!project.exists)
			project.create(null)
		if (!project.open)
			project.open(null)
		src = project.getFolder("src")
		if (!src.exists)
			src.create(true, true, null)
		topPackage = FileUtils.createPackage(src, projectName)
	}
	
	public def generatePublisherProject(EList<Sensor> sensors) {
		generateProjectFile
		generateClasspathFile
		generateBuildProperties
		generateSettings
		generateManifest
		generateMqttPublisher(sensors)
		generateMain
	}
	
	private def generateProjectFile() {
		val projectFile = project.getFile(".project")
		val fileContent = '''
			<?xml version="1.0" encoding="UTF-8"?>
			<projectDescription>
				<name>«projectName»</name>
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
		if (projectFile.exists)
			projectFile.delete(true, null)
		val source = new ByteArrayInputStream(fileContent.bytes)
		projectFile.create(source, true, null)
	}
	
	private def generateClasspathFile() {
		val classpathFile = project.getFile(".classpath")
		val fileContent = '''
			<?xml version="1.0" encoding="UTF-8"?>
			<classpath>
				<classpathentry kind="con" path="org.eclipse.jdt.launching.JRE_CONTAINER/org.eclipse.jdt.internal.debug.ui.launcher.StandardVMType/JavaSE-1.8"/>
				<classpathentry kind="con" path="org.eclipse.pde.core.requiredPlugins"/>
				<classpathentry kind="src" path="src"/>
				<classpathentry kind="output" path="bin"/>
			</classpath>
		'''
		if (classpathFile.exists)
			classpathFile.delete(true, null)
		val source = new ByteArrayInputStream(fileContent.bytes)
		classpathFile.create(source, true, null)
	}
	
	private def generateBuildProperties() {
		val buildProperties = project.getFile("build.properties")
		val fileContent = '''
			source.. = src/
			output.. = bin/
			bin.includes = META-INF/,\
			               .
		'''
		if (buildProperties.exists)
			buildProperties.delete(true, null)
		val source = new ByteArrayInputStream(fileContent.bytes)
		buildProperties.create(source, true, null)
	}
	
	private def generateSettings() {
		val settingsFolder = project.getFolder(".settings")
		if (!settingsFolder.exists)
			settingsFolder.create(true, true, null)
		val settingsFile = settingsFolder.getFile("org.eclipse.jdt.core.prefs")
		val fileContent = '''
			eclipse.preferences.version=1
			org.eclipse.jdt.core.compiler.codegen.inlineJsrBytecode=enabled
			org.eclipse.jdt.core.compiler.codegen.targetPlatform=1.8
			org.eclipse.jdt.core.compiler.compliance=1.8
			org.eclipse.jdt.core.compiler.problem.assertIdentifier=error
			org.eclipse.jdt.core.compiler.problem.enumIdentifier=error
			org.eclipse.jdt.core.compiler.source=1.8
		'''
		if (settingsFile.exists)
			settingsFile.delete(true, null)
		val source = new ByteArrayInputStream(fileContent.bytes)
		settingsFile.create(source, true, null)
	}
	
	private def generateManifest() {
		val metainfFolder = project.getFolder("META-INF")
		if (!metainfFolder.exists)
			metainfFolder.create(true, true, null)
		val manifestFile = metainfFolder.getFile("MANIFEST.MF")
		val fileContent = '''
			Manifest-Version: 1.0
			Bundle-ManifestVersion: 2
			Bundle-Name: Publisher
			Bundle-SymbolicName: «projectName»
			Bundle-Version: 1.0.0.qualifier
			Bundle-RequiredExecutionEnvironment: JavaSE-1.8
			Require-Bundle: com.incquerylabs.iot.javatransmitter;bundle-version="1.0.0",
			 com.eclipsesource.json;bundle-version="1.0.0",
			 org.eclipse.viatra.cep.mqtt.commons;bundle-version="1.0.0",
			 org.eclipse.paho.client.mqttv3;bundle-version="1.0.2"
		'''
		if (manifestFile.exists)
			manifestFile.delete(true, null)
		val source = new ByteArrayInputStream(fileContent.bytes)
		manifestFile.create(source, true, null)
	}
	
	private def generateMqttPublisher(EList<Sensor> sensors) {
		val publisherFile = topPackage.getFile("MqttPublisher.java")
		val fileContent = '''
			package «projectName»;
			
			import java.util.concurrent.BlockingQueue;
			
			import com.eclipsesource.json.JsonObject;
			import com.incquerylabs.iot.javatransmitter.data.InputParameters;
			import com.incquerylabs.iot.javatransmitter.runnables.MqttPublisherRunnable;
			
			public class MqttPublisher extends MqttPublisherRunnable {
			
				public MqttPublisher(BlockingQueue<String> queue, InputParameters parameters) {
					super(queue, parameters);
				}
				
				@Override
				public void run() {
					try {
					   	System.out.println("Start sending messages...");
				   	   	while(isRunning) {
					   	   	String rawData = queue.take();
					   	   	JsonObject sensors = JsonObject.readFrom(rawData);
					   	   	for (String sensorName : sensors.names()) {
								«FOR sensor:sensors»
									«FOR parameter:sensor.lastReceivedPayload.dataParameters»
										«IF sensors.indexOf(sensor) == 0»
										if (sensorName.equals("pb1")) {
											JsonObject jsonMessage = sensors.get(sensorName).asArray().get(0).asObject();
											JsonObject jsonValue = jsonMessage.get("messageName").asObject();
											JsonObject param = new JsonObject().add("«parameter.name»", jsonValue.get("value").asInt());
											JsonObject msg = new JsonObject().add("«sensor.lastReceivedPayload.name»", param);
											publisher.publish("«sensor.name»", msg.toString());
										}
										«ELSEIF sensors.indexOf(sensor) == 1»
										if (sensorName.equals("pb2")) {
											JsonObject jsonMessage = sensors.get(sensorName).asArray().get(0).asObject();
											JsonObject jsonValue = jsonMessage.get("messageName").asObject();
											JsonObject param = new JsonObject().add("«parameter.name»", jsonValue.get("value").asInt());
											JsonObject msg = new JsonObject().add("«sensor.lastReceivedPayload.name»", param);
											publisher.publish("«sensor.name»", msg.toString());
										}
										«ELSEIF sensors.indexOf(sensor) == 2»
										if (sensorName.equals("pb3")) {
											JsonObject jsonMessage = sensors.get(sensorName).asArray().get(0).asObject();
											JsonObject jsonValue = jsonMessage.get("messageName").asObject();
											JsonObject param = new JsonObject().add("«parameter.name»", jsonValue.get("value").asInt());
											JsonObject msg = new JsonObject().add("«sensor.lastReceivedPayload.name»", param);
											publisher.publish("«sensor.name»", msg.toString());
										}
										«ELSEIF sensors.indexOf(sensor) == 3»
										if (sensorName.equals("pot1")) {
											JsonObject jsonMessage = sensors.get(sensorName).asArray().get(0).asObject();
											JsonObject jsonValue = jsonMessage.get("messageName").asObject();
											JsonObject param = new JsonObject().add("«parameter.name»", jsonValue.get("value").asInt());
											JsonObject msg = new JsonObject().add("«sensor.lastReceivedPayload.name»", param);
											publisher.publish("«sensor.name»", msg.toString());
										}
										«ENDIF»
									«ENDFOR»
								«ENDFOR»
							}
						}
					} catch (InterruptedException e) {
				   		LOGGER.error("Interrupted", e);
					}
				}
			
			}
		'''
		if (publisherFile.exists)
			publisherFile.delete(true, null)
		val source = new ByteArrayInputStream(fileContent.bytes)
		publisherFile.create(source, true, null)
	}
	
	private def generateMain() {
		val mainFile = topPackage.getFile("Main.java")
		val fileContent = '''
			package «projectName»;
			
			import java.util.concurrent.ArrayBlockingQueue;
			import java.util.concurrent.BlockingQueue;
			
			import com.incquerylabs.iot.javatransmitter.data.InputParameters;
			import com.incquerylabs.iot.javatransmitter.runnables.EmulatedFeeder;
			import com.incquerylabs.iot.javatransmitter.runnables.SerialPortEmulator;
			import com.incquerylabs.iot.javatransmitter.runnables.SerialPortListener;
			import com.incquerylabs.iot.javatransmitter.utils.ArgumentUtils;
			
			public class Main {
			
				public static void main(String[] args) throws Exception {
					InputParameters parsedArgs = ArgumentUtils.parseArgs(args);
					if (ArgumentUtils.validateParsedArgs(parsedArgs)){
						if (parsedArgs.help){
							displayHelp();
							System.exit(1);
						} else {
							ArgumentUtils.displayParsedArgs(parsedArgs);
							BlockingQueue<String> queue = new ArrayBlockingQueue<String>(1024);
				
							// MQTT Publisher
							MqttPublisher publisher = new MqttPublisher(queue, parsedArgs);
							new Thread(publisher).start();
							
							// Serial Port
							if (parsedArgs.emaulteSerial){
								BlockingQueue<String> queueBtwEmulatorAndFeeder = new ArrayBlockingQueue<String>(1024);
								SerialPortEmulator emulator = new SerialPortEmulator(queueBtwEmulatorAndFeeder);
								EmulatedFeeder feeder = new EmulatedFeeder(queueBtwEmulatorAndFeeder, queue);
								new Thread(emulator).start();
								new Thread(feeder).start();
							} else {
								SerialPortListener serialListener = new SerialPortListener();
								serialListener.listen(parsedArgs, queue);
							}
						}
					} else {
						System.err.println("Invalid porgram arguments.");
						System.exit(0);
					}
				}
			
				private static void displayHelp() {
					System.out.println("=============== HELP ===============");
					System.out.println("-h | -help: Display help message.");
					System.out.println();
					System.out.println("-es: Emulate Serial. When Arduino is not available, the user is able to emulate serial communication with console inputs.");
					System.out.println();
					System.out.println("-port: Specify the name of the SerialPort.");
					System.out.println("   e.g.:");
					System.out.println("      Windows: COM3");
					System.out.println("      Mac OS X: /dev/tty.usbserial-A9007UX1");
					System.out.println("      Linux: /dev/ttyUSB0");
					System.out.println();
					System.out.println("-broker: Specify the url of the MQTT broker. (e.g.: tcp://localhost:1883)");
					System.out.println();
					System.out.println("-topic: Specify the target topic. (e.g.: data/LH)");
					System.out.println();
					System.out.println("-sensorID: Specify the SensorID. (e.g.: LH)");
					System.out.println();
					System.out.println("====================================");
				}
				
			}
		'''
		if (mainFile.exists)
			mainFile.delete(true, null)
		val source = new ByteArrayInputStream(fileContent.bytes)
		mainFile.create(source, true, null)
	}
	
}