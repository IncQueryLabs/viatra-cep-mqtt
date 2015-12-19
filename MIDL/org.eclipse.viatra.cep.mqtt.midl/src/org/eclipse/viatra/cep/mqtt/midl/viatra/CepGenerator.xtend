package org.eclipse.viatra.cep.mqtt.midl.viatra

import java.io.ByteArrayInputStream
import java.util.regex.Pattern
import org.eclipse.core.resources.IFolder
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.common.util.URI
import org.eclipse.viatra.cep.mqtt.midl.mIDL.MqttSetup
import org.eclipse.viatra.cep.mqtt.midl.mIDL.Sensor
import org.eclipse.viatra.cep.mqtt.midl.utils.FileUtils

class CepGenerator {
	
	IProject project
	IFolder srcgen
	IFolder topPackage
	String projectName
	String modelPath
	
	new(String rootPath, URI uri) {
		this.projectName = uri.segments.get(1)
		val workspace = ResourcesPlugin.workspace.root
		project = workspace.getProject(projectName)
		srcgen = project.getFolder("src-gen")
		if (!srcgen.exists)
			srcgen.create(true, true, null)
		val srcgencontent = srcgen.getFile(projectName.split(Pattern.quote(".")).get(0))
		if (srcgencontent.exists)
			srcgencontent.delete(true, null)
		topPackage = FileUtils.createPackage(srcgen, projectName)
		this.modelPath =  workspace.location.toOSString.replace("\\", "/") + uri.toPlatformString(true);
	}
	
	public def generateCepProject(EList<Sensor> sensors, MqttSetup setup){
		generateCepApplication(sensors, setup)
		generateManifestFile
		val patternGenerator = new PatternGenerator
		patternGenerator.generatePatternsAndRules(topPackage, sensors, projectName)
	}
	
	private def generateManifestFile() {
		val metainfFolder = project.getFolder("META-INF")
		val manifestFile = metainfFolder.getFile("MANIFEST.MF")
		val fileContent = '''
			Manifest-Version: 1.0
			Bundle-ManifestVersion: 2
			Bundle-Name: «projectName»
			Bundle-SymbolicName: «projectName»;singleton:=true
			Bundle-Version: 1.0.0.qualifier
			Export-Package: «projectName».eiq,
			 «projectName».eiq.util,
			 «projectName».vepl.firstLevel,
			 «projectName».vepl.firstLevel.events.queryresult,
			 «projectName».vepl.firstLevel.jobs,
			 «projectName».vepl.firstLevel.mapping,
			 «projectName».vepl.firstLevel.patterns.atomic.queryresult,
			 «projectName».vepl.firstLevel.rules
			Require-Bundle: org.eclipse.emf.ecore,
			 org.eclipse.incquery.runtime,
			 org.eclipse.xtext.xbase.lib,
			 org.eclipse.viatra.cep.core;bundle-version="0.8.0",
			 org.eclipse.emf.mwe.utils;bundle-version="1.3.20",
			 org.eclipse.viatra.cep.mqtt.commons;bundle-version="1.0.0",
			 org.eclipse.viatra.cep.mqtt.midl;bundle-version="1.0.0",
			 org.eclipse.xtext;bundle-version="2.9.0",
			 org.eclipse.paho.client.mqttv3;bundle-version="1.0.2",
			 org.junit;bundle-version="4.12.0"
			Bundle-RequiredExecutionEnvironment: JavaSE-1.8
			Import-Package: org.apache.log4j
		'''
		if (manifestFile.exists)
			manifestFile.delete(true, null)
		val source = new ByteArrayInputStream(fileContent.bytes)
		manifestFile.create(source, true, null)
	}
	
	private def generateCepApplication(EList<Sensor> sensors, MqttSetup setup) {
		val cepApplicationFile = topPackage.getFile("CepApplication.java")
		val fileContent = '''
			package «projectName»;
			
			import org.eclipse.emf.common.util.URI;
			import org.eclipse.emf.ecore.resource.Resource;
			import org.eclipse.emf.mwe.utils.StandaloneSetup;
			import org.eclipse.viatra.cep.core.api.engine.CEPEngine;
			import org.eclipse.viatra.cep.core.metamodels.automaton.EventContext;
			import org.eclipse.viatra.cep.core.streams.EventStream;
			import org.eclipse.viatra.cep.mqtt.commons.mqtt.Callback;
			import org.eclipse.viatra.cep.mqtt.commons.mqtt.Subscriber;
			import org.eclipse.viatra.cep.mqtt.midl.MIDLStandaloneSetup;
			import org.eclipse.viatra.cep.mqtt.midl.mIDL.IoTSystem;
			import org.eclipse.xtext.resource.XtextResource;
			import org.eclipse.xtext.resource.XtextResourceSet;
			import org.junit.Before;
			import org.junit.Test;
			
			import com.google.inject.Injector;
			
			import «projectName».vepl.firstLevel.CepFactory;
			import «projectName».vepl.firstLevel.mapping.QueryEngine2ViatraCep;
			
			public class CepApplication {
			
				private CEPEngine engine;
				private QueryEngine2ViatraCep mapping;
				public EventStream eventStream;
				public CepFactory cepFactory;
				
				protected Resource resource;
				protected XtextResourceSet resourceSet;
				
				Subscriber subscriber;
				Callback callback;
				String brokerAddress = "«setup.brokerUrl»";
				String uriAddress = "file:/«modelPath»";
				boolean running = false;
			
				@Before
				public void setUp() {
					engine = CEPEngine.newEngine().eventContext(EventContext.STRICT_IMMEDIATE)
							.rules(CepFactory.getInstance().allRules()).prepare();
					eventStream = engine.getStreamManager().newEventStream();
			
					new StandaloneSetup().setPlatformUri("../");
					Injector injector = new MIDLStandaloneSetup().createInjectorAndDoEMFRegistration();
					resourceSet = injector.getInstance(XtextResourceSet.class);
					resourceSet.addLoadOption(XtextResource.OPTION_RESOLVE_ALL, Boolean.TRUE);
					resource = resourceSet.getResource(URI.createURI(uriAddress), true);
					mapping = QueryEngine2ViatraCep.register(resourceSet, eventStream);
					
					callback = new Callback((IoTSystem) resource.getContents().get(0));
					subscriber = new Subscriber(brokerAddress, "CEP_SUBSCRIBER");
					subscriber.setCallback(callback);

					running = true;
				}
			
				@Test
				public void run() {
					subscriber.connect();
					«FOR sensor:sensors»
					subscriber.subscribe("«sensor.name»");
					«ENDFOR»
					while (running) {
			
					}
					mapping.dispose();
					subscriber.disconnect();
				}
			
			}
		'''
		if (cepApplicationFile.exists)
			cepApplicationFile.delete(true, null)
		val source = new ByteArrayInputStream(fileContent.bytes)
		cepApplicationFile.create(source, true, null)
	}
	
}