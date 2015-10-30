# VIATRA-CEP: MQTT integration demo

A demo for EclipseCon Europe 2015, more details at the [ECE website](https://www.eclipsecon.org/europe2015/session/iot-supercharged-complex-event-processing-mqtt-eclipse-technologies)

## Getting started

The instructions below were tested on Ubuntu 14.04 LTS.

### Arduino setup
Install driver: `sudo apt-get update && sudo apt-get install arduino arduino-core`
If something doesn't work, sudo copy _librxtxSerial.so_ (from _Sensors/com.incquerylabs.iot.javatransmitter/exported_) to _/usr/lib/_

### Mosquito broker and cliente

1. Install docker: `sudo apt-get -y install docker.io`
2. Pull and start appropriate mosquitto image `docker run -tip 1883:1883 -p 9001:9001 toke/mosquitto`
3. Install mosquito client: `sudo apt-get install mosquito-clients`
4. Start mosquito_sub (in a separate terminal) to see output from demo device: `mosquitto_sub -p 1883 -t "data/LH"`


### Eclipse

#### Developer workspace

0. Start with an Eclipse Modeling setup, for Eclipse Mars.1
1. Install m2e (Maven for Eclipse) from the Mars update site
2. Install the latest [Xtext 2.9](http://download.eclipse.org/modeling/tmf/xtext/updates/composite/latest/), tested version: 201510290501
3. Install [EMF-IncQuery 1.1.0](https://hudson.eclipse.org/incquery/job/incquery-master/lastSuccessfulBuild/artifact/update-site/), tested version: 201510281452
4. Install [Viatra CEP 0.8.0](https://hudson.eclipse.org/viatra/job/viatra-master/lastSuccessfulBuild/artifact/releng/org.eclipse.viatra.update/target/repository/) from CI update site, tested version: 201510251802
5. Import the MIDL projects (_org.eclipse.viatra.cep.mqtt.midl_ and TODO generator) from this git repository into your workspace, and run the _org.eclipse.viatra.cep.mqtt.midl/src/org/eclipse/viatra/cep/mqtt/midl/GenerateMIDL.mwe2_ script to generate the MIDL Xtext projects.

Note: after [Xtext 2.9.0](https://projects.eclipse.org/projects/modeling.tmf.xtext/releases/2.9.0), [EMF-IncQuery 1.1.0](https://projects.eclipse.org/projects/modeling.incquery/releases/1.1.0) and [VIATRA 0.8.0](https://projects.eclipse.org/projects/modeling.viatra/releases/0.8.0) are released, you can replace the above CI versions with these release versions, installable from their standard update sites as well as Marketplace entries.

#### Runtime workspace

1. Clone [Paho Java](http://git.eclipse.org/gitroot/paho/org.eclipse.paho.mqtt.java.git) library and import the _org.eclipse.paho.client.mqttv3_ project to the workspace, ignore the compile error in the _pom.xml_ file
2. Import the following projects into your workspace from this git repository: _com.eclipsesource.json_, _com.incquerylabs.iot.javatransmitter_, _com.incquerylabs.iot.demo.dashboard_, _com.incquerylabs.iot.demo.cep_)
3. Make sure everything builds cleanly.

## Trying the demo

* freeboard main, point your browser at localhost:8080
* runEmulator.sh
 * possible inputs 
* runWithDefaultParameters.sh
