package com.incquerylabs.iot.demo.dashboard

import org.eclipse.jetty.server.Server

class DashboardServer {
	
	private Server server;
	
	public static int SERVER_PORT = 8080;
	
	new () {
		this(8080)
	}
	
	new (int port) {
		SERVER_PORT = port;
		server = new Server(port)
		server.handler = ServerContextBuilder.buildHandlers
	}
	
	def startServer() throws Exception {
		server?.start
		server?.join
	}
	
	def isStarted() {
		server.started
	}
	
	def stopServer() throws Exception {
		server?.stop
	}
	
}
