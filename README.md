# VIATRA-CEP: MQTT integration demo

A demo for EclipseCon Europe 2015, more details at the [ECE website](https://www.eclipsecon.org/europe2015/session/iot-supercharged-complex-event-processing-mqtt-eclipse-technologies)

## Getting started
### Arduino

1. Install driver: `sudo apt-get update && sudo apt-get install arduino arduino-core`
2. Copy _librxtxSerial.so_ to _/usr/lib/_

### Mosquitto broker

1. Install docker: `sudo apt-get -y install docker.io`
2. Pull and start appropriate mosquitto image `docker run -tip 1883:1883 -p 9001:9001 toke/mosquitto`

### Eclipse

1. Install [Viatra CEP](https://hudson.eclipse.org/viatra/job/viatra-master/lastSuccessfulBuild/artifact/releng/org.eclipse.viatra.update/target/repository/) from CI update site.
2. Install [Xtext 2.9](http://download.eclipse.org/modeling/tmf/xtext/updates/composite/milestones/)
3. Clone [Paho Java](http://git.eclipse.org/gitroot/paho/org.eclipse.paho.mqtt.java.git) library and import to the workspace
