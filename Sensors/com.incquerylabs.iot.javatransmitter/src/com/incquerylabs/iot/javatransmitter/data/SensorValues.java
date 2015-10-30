package com.incquerylabs.iot.javatransmitter.data;

public class SensorValues {
	public boolean pb1 = false;
	public boolean pb2 = false;
	public boolean pb3 = false;
	public int pot1 = 0; // 0 - 1023
	
	public SensorValues() {
		// TODO Auto-generated constructor stub
	}
	
	public SensorValues(String pb1, String pb2, String pb3, String pot1) {
		super();
		this.pb1 = convertToBooleanValue(pb1);
		this.pb2 = convertToBooleanValue(pb2);
		this.pb3 = convertToBooleanValue(pb3);
		try{
			this.pot1 = Integer.parseInt(pot1);
		}catch(NumberFormatException e){
			this.pot1 = 0;
		}
	}
	
	private boolean convertToBooleanValue(String input){
		return (input != null && input.equals("1")) ? true : false;
	}
	
	@Override
	public String toString() {
		return "  "+convertToOnOffValue(pb1)+"\t\t  "+convertToOnOffValue(pb2)+"\t\t  "+convertToOnOffValue(pb3)+"\t\t       " + pot1;
	}
	
	private String convertToOnOffValue(boolean b){
		return b ? "ON" : "OFF";
	}
	
	public void print(){
		System.out.println(this);
	}
	
	public int getPb1IntValue() {
		return pb1 ? 1 : 0;
	}
	
	public int getPb2IntValue() {
		return pb2 ? 1 : 0;
	}
	
	public int getPb3IntValue() {
		return pb3 ? 1 : 0;
	}
	
	public String createJSONString() {
		return "{\"pb1\" : [{\"messageName\": {\"value\" : "+getPb1IntValue()+"}}], \"pb2\" : [{\"messageName\": {\"value\" : "+getPb2IntValue()+"}}], \"pb3\" : [{\"messageName\": {\"value\" : "+getPb3IntValue()+"}}], \"pot1\" : [{\"messageName\": {\"value\" : "+pot1+"}}]}";
	}
	
};
