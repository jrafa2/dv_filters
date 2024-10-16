`ifndef _I2C_SEQ
`define _I2C_SEQ

`include "transaction_i2c.sv"

class i2c_basic_seq extends uvm_sequence#(i2c_basic_tr);
  byte i2c_addr;  //register address
  byte i2c_data;  //register value
  bit i2c_read;   //1: read; 0: write
  
  `uvm_object_utils(i2c_basic_seq)
  
  function new(string name = "i2c_basic_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "i2c_basic_seq created", UVM_LOW)
    `uvm_do_with(req, { req.addr == i2c_addr;
                        req.data == i2c_data;
                        req.read == i2c_read; });
  endtask : body
endclass : i2c_basic_seq

`endif // _I2C_SEQ
