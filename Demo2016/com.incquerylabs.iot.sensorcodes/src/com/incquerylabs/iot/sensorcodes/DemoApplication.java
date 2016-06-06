package com.incquerylabs.iot.sensorcodes;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.mwe.utils.StandaloneSetup;
import org.eclipse.paho.client.mqttv3.MqttCallback;
import org.eclipse.viatra.cep.core.api.engine.CEPEngine;
import org.eclipse.viatra.cep.core.metamodels.automaton.EventContext;
import org.eclipse.viatra.cep.core.metamodels.events.Event;
import org.eclipse.viatra.cep.core.streams.EventStream;
import org.eclipse.viatra.cep.mqtt.commons.mqtt.Callback;
import org.eclipse.viatra.cep.mqtt.commons.mqtt.Publisher;
import org.eclipse.viatra.cep.mqtt.commons.mqtt.Subscriber;
import org.eclipse.viatra.cep.mqtt.midl.MIDLStandaloneSetup;
import org.eclipse.viatra.cep.mqtt.midl.mIDL.IoTSystem;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.resource.XtextResourceSet;
import org.junit.After;

import com.google.inject.Injector;
import com.incquerylabs.iot.sensorcodes.events.CepFactory;
import com.incquerylabs.iot.sensorcodes.events.mapping.QueryEngine2ViatraCep;

public class DemoApplication implements IEventStreamProvider {
	
	public static enum APP_MODE {
		DIRECT_PUSH,
		RUNTIME_UPDATE
	}
	
	APP_MODE appMode;
	
	String brokerAddress = "tcp://127.0.0.1:1883";
	
	protected CEPEngine engine;
	protected QueryEngine2ViatraCep mapping;
	
	public EventStream eventStream;
	public CepFactory cepFactory;
	
	protected Resource resource;
	protected XtextResourceSet resourceSet;
	
	ExecutorService pool = Executors.newCachedThreadPool();
	
	Publisher triggerPublisher; 
	
	boolean sensorTriggerRunning = false;
	
	String uriAddress = "file:/home/pi/demo/demo.midl";
	boolean running = false;
	
	Subscriber subscriber;
	MqttCallback callback;
	
	private Thread triggerThread = new Thread(new Runnable() {
		
		@Override
		public void run() {
			sensorTriggerRunning = true;

			while(sensorTriggerRunning) {
				if(triggerPublisher.isConnected())
					triggerPublisher.publish("sensor/trigger", new Long(System.currentTimeMillis()).toString());
				try {
					Thread.sleep(200);
				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
			
		}
	});
	
	private static DemoApplication instance = null;
	
	public static DemoApplication getInstance() throws InterruptedException {
		if(instance == null) {
			instance = new DemoApplication(APP_MODE.DIRECT_PUSH);
		}
		return instance;
	}
	
	private DemoApplication() {}
	
	private DemoApplication(APP_MODE mode) throws InterruptedException {
		
		engine = CEPEngine.newEngine().eventContext(EventContext.STRICT_IMMEDIATE)
				.rules(CepFactory.getInstance().allRules()).prepare();
		eventStream = engine.getStreamManager().newEventStream();
		
		this.appMode = mode;
		
	}

	public void start() throws InterruptedException {
		
		String brokerUrl = System.getProperty("brokerUrl");
		
		if(brokerUrl != null) {
			brokerAddress = brokerUrl;
		}
		
		triggerPublisher = new Publisher(brokerAddress, "sensor_trigger_" + System.currentTimeMillis());
		triggerPublisher.connect();
		
		String midlUri = System.getProperty("midlUri");
		
		if(midlUri != null) {
			uriAddress = midlUri;
		}
		
		new StandaloneSetup().setPlatformUri("../");
		Injector injector = new MIDLStandaloneSetup().createInjectorAndDoEMFRegistration();
		resourceSet = injector.getInstance(XtextResourceSet.class);
		resourceSet.addLoadOption(XtextResource.OPTION_RESOLVE_ALL, Boolean.TRUE);
		
		resource = resourceSet.getResource(URI.createURI(uriAddress), true);
		
		QueryEngine2ViatraCep.register(resourceSet, eventStream);
		
		if(appMode == APP_MODE.DIRECT_PUSH) {
			callback = new DirectPushCallback(this);							  // callback to push events directly to stream			
		} else {
			callback = new Callback((IoTSystem) resource.getContents().get(0));   // callback to update runtime model
		}
		
		subscriber = new Subscriber(brokerAddress, "CEP_SUBSCRIBER");
		subscriber.setCallback(callback);
		
		subscriber.connect();
		
		subscriber.subscribe("sensor/player4/HEAD/data");
		subscriber.subscribe("sensor/player4/RL/data");
		subscriber.subscribe("sensor/player4/LL/data");
		subscriber.subscribe("sensor/player4/RH/data");
		subscriber.subscribe("sensor/player4/LH/data");
		
		System.out.println("Demo application started ... ");
		
		// Start sensor trigger thread
		pool.execute(triggerThread);
		
		running = true;
		
//		pushINIT_ATOM();
		
		while(running) {
			
			if(!triggerPublisher.isConnected()) {
				System.out.println("Trigger connection lost. Reconnecting ...");
				triggerPublisher.connect();
			}
			
			if(!subscriber.isConnected()) {
				System.out.println("Subscriber connection lost. Reconnecting ...");
				subscriber.connect();
			}
			
			Thread.sleep(3000);
		}

	}
	
	@After
	public void stop() {
		sensorTriggerRunning = false;
		running = false;
		pool.shutdownNow();
	}

	@Override
	synchronized public void pushEvent(Event event) {
		eventStream.push(event);
	}

	public void pushINIT_ATOM() throws InterruptedException {
		pushEvent(CepFactory.getInstance().createINIT_ATOM_Event());
		pushEvent(CepFactory.getInstance().createINIT_ATOM_Event());
		pushEvent(CepFactory.getInstance().createINIT_ATOM_Event());
		pushEvent(CepFactory.getInstance().createINIT_ATOM_Event());
	}
	
}
