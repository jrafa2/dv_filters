`ifndef _I2C_DRV
`define _I2C_DRV

class i2c_driver extends uvm_driver #(i2c_basic_tr);
  i2c_basic_tr req;
  int period_ns = 1000;
  `uvm_component_utils(i2c_driver)

  virtual dut_if dut_vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
  endfunction : build_phase
  
  function void connect_phase(uvm_phase phase);
    assert(uvm_config_db#(virtual dut_if)::get(this, "", "dut_if", dut_vif));  
  endfunction

  task run_phase(uvm_phase phase);
    byte         first_byte, second_byte, third_byte;
    bit          ack;
    
    dut_vif.scl_drive = 1;
    forever begin
      fork
        forever begin
          dut_vif.scl_drive = 0;
          dut_vif.sda_val = 0;
          dut_vif.sda_drive = 0;
          
          seq_item_port.get_next_item(req);
          `uvm_info("I2C", $sformatf("Drv writes %p", req), UVM_LOW);
          dut_vif.scl_drive = 1;

          // Send device address and r/w operation
          first_byte = {req.device_addr[6:0], !req.read};
          set_start();
          set_byte(first_byte);
          get_ack(ack);
         //if(!ack == 0) break;

          // Send register address
          second_byte = req.addr;
          set_byte(second_byte);
          get_ack(ack);

          if(req.read) begin
            // Read operation --> don't care about data to send, just send 'z
            set_byte(8'bz);
            set_ack(ack);
          end else begin
            // Write operation --> send register value
            third_byte = req.data;
            set_byte(third_byte);
            get_ack(ack);
          end

          //Stop condition
          set_stop();
          #2 seq_item_port.item_done();
        end
      join_any;
      disable fork;
      
    end
  endtask : run_phase
  
  local task set_start();
    dut_vif.sda_drive = 1;
    dut_vif.scl_val = 1;
    dut_vif.sda_val = 0;
    #(period_ns*1ns);
    dut_vif.scl_val = 0;
    #(period_ns*1ns);
  endtask
        
  local task set_byte(logic[7:0] b);		//we assume SCLK=0, toggle data in posedge
    dut_vif.sda_drive = 1;  //get the use of the data line
    repeat(8) begin
      dut_vif.sda_val = b[7];
      b = b << 1;
      #(period_ns*1ns);
      dut_vif.scl_val = !dut_vif.scl_val;
      #(period_ns*1ns);
      dut_vif.scl_val = !dut_vif.scl_val;
//      #(period_ns*1ns);
    end
    dut_vif.sda_drive = 0;  //allow slave to set ACK
  endtask
  
  local task get_ack(output logic ack);
    dut_vif.sda_drive = 0;
    dut_vif.scl_val = 0;
    #(period_ns*1ns);
    dut_vif.scl_val = 1;
    #(period_ns*1ns);
    dut_vif.scl_val = 0;
    #(period_ns*1ns);
    ack = dut_vif.sdata;
    
  endtask
        
  local task set_stop();
    dut_vif.sda_drive = 1;
    #(period_ns*1ns);
    dut_vif.sda_val = 0;
    dut_vif.scl_val = 0;
    #(period_ns*1ns);
    dut_vif.scl_val = 1;
    #(period_ns*1ns);
    dut_vif.sda_val = 1;
  endtask
  
  local task set_ack(logic ack = 1);
    dut_vif.sda_drive = 1;
    #(period_ns*1ns);
    dut_vif.sda_val = ack;
    dut_vif.scl_val = 1;
    #(period_ns*1ns);
    ack = dut_vif.sdata;
    dut_vif.scl_val = 0;
    dut_vif.sda_drive = 0;
  endtask
  
endclass: i2c_driver

`endif // _I2C_DRV
