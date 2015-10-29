package com.incquerylabs.iot.demo.cep;

import java.util.Map;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl;
import org.eclipse.paho.client.mqttv3.IMqttDeliveryToken;
import org.eclipse.paho.client.mqttv3.MqttCallback;
import org.eclipse.paho.client.mqttv3.MqttMessage;
import org.eclipse.viatra.cep.core.api.engine.CEPEngine;
import org.eclipse.viatra.cep.core.metamodels.automaton.EventContext;
import org.eclipse.viatra.cep.core.streams.EventStream;
import org.eclipse.viatra.cep.mqtt.midl.mIDL.IntParameter;
import org.eclipse.viatra.cep.mqtt.midl.mIDL.MIDLFactory;
import org.eclipse.viatra.cep.mqtt.midl.mIDL.Machine;
import org.eclipse.viatra.cep.mqtt.midl.mIDL.Message;
import org.eclipse.viatra.cep.mqtt.midl.mIDL.Sensor;

import com.eclipsesource.json.JsonObject;
import com.incquerylabs.iot.demo.cep.mqtt.Publisher;
import com.incquerylabs.iot.demo.cep.mqtt.Subscriber;
import com.incquerylabs.iot.demo.cep.vepl.CepFactory;
import com.incquerylabs.iot.demo.cep.vepl.mapping.QueryEngine2ViatraCep;

public class CEPApplication implements MqttCallback {

	private CEPEngine engine;
	private QueryEngine2ViatraCep mapping;
	public EventStream eventStream;
	public CepFactory cFactory;
	
	private Subscriber subscriber;
	public static Publisher publisher;
	
	protected Resource resource;
	protected ResourceSet resourceSet;
	
	boolean running = false;
	
	Machine machine = MIDLFactory.eINSTANCE.createMachine();

	Sensor btn1 = MIDLFactory.eINSTANCE.createSensor();
	Sensor btn2 = MIDLFactory.eINSTANCE.createSensor();
	Sensor btn3 = MIDLFactory.eINSTANCE.createSensor();
	Sensor pot1 = MIDLFactory.eINSTANCE.createSensor();

	Message btn_msg1 = MIDLFactory.eINSTANCE.createMessage();
	Message btn_msg2 = MIDLFactory.eINSTANCE.createMessage();
	Message btn_msg3 = MIDLFactory.eINSTANCE.createMessage();
	Message pot_msg1 = MIDLFactory.eINSTANCE.createMessage();

	IntParameter btn_msg_data1 = MIDLFactory.eINSTANCE.createIntParameter();
	IntParameter btn_msg_data2 = MIDLFactory.eINSTANCE.createIntParameter();
	IntParameter btn_msg_data3 = MIDLFactory.eINSTANCE.createIntParameter();
	IntParameter pot_msg_data1 = MIDLFactory.eINSTANCE.createIntParameter();

	public CEPApplication() {
		engine = CEPEngine.newEngine().eventContext(EventContext.STRICT_IMMEDIATE)
				.rules(CepFactory.getInstance().allRules()).prepare();
		eventStream = engine.getStreamManager().newEventStream();
		Resource.Factory.Registry reg = Resource.Factory.Registry.INSTANCE;
		Map<String, Object> m = reg.getExtensionToFactoryMap();
		m.put("model", new XMIResourceFactoryImpl());
		resourceSet = new ResourceSetImpl();
		resource = resourceSet.createResource(URI.createURI("model/sensors.model"));
		
		btn_msg_data1.setName("value");
		btn_msg_data2.setName("value");
		btn_msg_data3.setName("value");
		pot_msg_data1.setName("value");

		btn_msg1.getDataParameters().add(btn_msg_data1);
		btn_msg2.getDataParameters().add(btn_msg_data2);
		btn_msg3.getDataParameters().add(btn_msg_data3);
		pot_msg1.getDataParameters().add(pot_msg_data1);
		
		btn1.setName("btn1");
		btn2.setName("btn2");
		btn3.setName("btn3");
		pot1.setName("pot1");
		
		btn1.getMessages().add(btn_msg1);
		btn2.getMessages().add(btn_msg2);
		btn3.getMessages().add(btn_msg3);
		pot1.getMessages().add(pot_msg1);

		resource.getContents().add(btn1);
		resource.getContents().add(btn2);
		resource.getContents().add(btn3);
		resource.getContents().add(pot1);
		
		resource.getContents().add(btn_msg1);
		resource.getContents().add(btn_msg2);
		resource.getContents().add(btn_msg3);
		resource.getContents().add(pot_msg1);

		mapping = QueryEngine2ViatraCep.register(resourceSet, eventStream);
		
		subscriber = new Subscriber("tcp://127.0.0.1:1883", "IOT_CEP_DEMO_APP");
		subscriber.setCallback(this);
		subscriber.connect();
		subscriber.subscribe("data/LH");
		
		publisher = new Publisher("tcp://127.0.0.1:1883", "IOT_CEP_DEMO_");
		publisher.connect();

		
		running = true;
	}

	public void run() {
		while (running) {
			//eventStream.push(CepFactory.getInstance().createBtn1Btn_msgValueEqEvent_Event());
		}
		mapping.dispose();
		publisher.disconnect();
		subscriber.unsubscribe("data/LH");
	}

	@Override
	public void connectionLost(Throwable cause) {
	}

	@Override
	public void deliveryComplete(IMqttDeliveryToken token) {
	}

	@Override
	public void messageArrived(String topic, MqttMessage message) throws Exception {

		String messagedata = new String(message.getPayload());
		JsonObject obj = JsonObject.readFrom(messagedata);
		JsonObject btn1 = obj.get("pb1").asObject();
		JsonObject btn2 = obj.get("pb2").asObject();
		JsonObject btn3 = obj.get("pb3").asObject();
		JsonObject pot1 = obj.get("pot1").asObject();

		btn_msg_data1.setValue(btn1.getInt("value", 0));
		btn_msg_data2.setValue(btn2.getInt("value", 0));
		btn_msg_data3.setValue(btn3.getInt("value", 0));
		pot_msg_data1.setValue(pot1.getInt("value", 0));
	}

}
