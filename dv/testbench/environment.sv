`include "agent_i2c.sv"

class environment extends uvm_env;  
  `uvm_component_utils(environment)
  
  i2c_agent i2c_agt;
  //other agents

  virtual dut_if dut_vif;
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction
	
  function void build_phase(uvm_phase phase);
    i2c_agt = i2c_agent::type_id::create("i2c_agt", this);
	//create other agents?
  endfunction

  function void connect_phase(uvm_phase phase);
    //interface from database 
  endfunction
endclass : environment
