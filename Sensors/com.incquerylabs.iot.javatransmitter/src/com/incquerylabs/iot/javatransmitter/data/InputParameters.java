package com.incquerylabs.iot.javatransmitter.data;

public class InputParameters {

	private static final String DEFAULT_PORT = "COM12";
	private static final String MQTT_HOST = "localhost";
	private static final String MQTT_PORT = "1883";
	private static final String MQTT_SENSOR_ID = "LH";
	private static final String MQTT_TOPIC = "data/" + MQTT_SENSOR_ID;
	
	public boolean help = false;
	public String port = DEFAULT_PORT;
	public String broker = "tcp://"+MQTT_HOST+":" + MQTT_PORT;
	public String topic = MQTT_TOPIC;
	public String sensorID = MQTT_SENSOR_ID;
	public boolean emaulteSerial = false;
	
}
