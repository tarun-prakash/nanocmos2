///////////////////////////////////////////////////////////////////
// File Name: digital_core.sv
// Engineer:  Tarun Prakash (tprakash@lbl.gov)
// Description: nanoCMOS synthesized digital core.  
//              Includes:
//              UARTs for inter-chip communcation
//              64-byte Register Map for configuration bits
//
//              Note that the "primary" is the chip writing to and reading
//              from the current chip. It could also be the FPGA.
//              The "secondary" is always the current chip.
//
///////////////////////////////////////////////////////////////////

module digital_core
    #(parameter NUMREGS = 16)   // number of configuration registers
    
    (output logic piso,// PRIMARY-IN-SECONDARY-OUT TX UART output bit
    
// ANALOG CORE CONFIGURATION SIGNALS
    output logic [3:0] enable_channel, // high to enable channel
    output logic frontend_polarity_sel, // 0 for NMOS RCG, 1 for PMOS
    output logic frontend_output_sel, // 0 for RCG output, 1 for OTA
    output logic int_polarity_sel, // 0 for positive, 1 for negative
    output logic [2:0] v_buff_ref_global, // global ref for both int stages
    output logic [7:0] v_buff_ref_fine0, // fine ref for both int stages
    output logic [7:0] v_buff_ref_fine1, // fine ref for both int stages
    output logic [7:0] v_buff_ref_fine2, // fine ref for both int stages
    output logic [7:0] v_buff_ref_fine3, // fine ref for both int stages
    output logic [7:0] v_fine_refp, // positive DAC reference 
    output logic [7:0] v_fine_refn, // negative DAC reference 
    output logic [7:0] v_ref_comp0, // opamp ref voltage
    output logic [7:0] v_ref_comp1, // opamp ref voltage
    output logic [7:0] v_ref_comp2, // opamp ref voltage
    output logic [7:0] v_ref_comp3, // opamp ref voltage
    output logic [2:0] v_comp_thresh_sout_global, // SOUT disc. thresh
    output logic [7:0] v_comp_thresh_sout_fine0, // SOUT disc. thresh
    output logic [7:0] v_comp_thresh_sout_fine1, // SOUT disc. thresh
    output logic [7:0] v_comp_thresh_sout_fine2, // SOUT disc. thresh
    output logic [7:0] v_comp_thresh_sout_fine3, // SOUT disc. thresh
    output logic [2:0] v_comp_thresh_fout_global, // FOUT disc. thresh
    output logic [7:0] v_comp_thresh_fout_fine0, // FOUT disc. thresh
    output logic [7:0] v_comp_thresh_fout_fine1, // FOUT disc. thresh
    output logic [7:0] v_comp_thresh_fout_fine2, // FOUT disc. thresh
    output logic [7:0] v_comp_thresh_fout_fine3, // FOUT disc. thresh
    output logic [2:0] v_baseline_rcg_global, // global baseline adjust
    output logic [7:0] v_baseline_rcg_fine0, // fine baseline adjust
    output logic [7:0] v_baseline_rcg_fine1, // fine baseline adjust
    output logic [7:0] v_baseline_rcg_fine2, // fine baseline adjust
    output logic [7:0] v_baseline_rcg_fine3, // fine baseline adjust
    output logic [7:0] v_thresh_midpt_vrg, // set threshold in vrg
    output logic [7:0] v_thresh_total_vrg_ch1, // set threshold in vrg
    output logic [7:0] v_thresh_partial_vrg_ch1, // set threshold in vrg
    output logic [7:0] v_thresh_hold_vrg_ch1, // set threshold in vrg
    output logic [7:0] v_thresh_total_vrg_ch3, // set threshold in vrg
    output logic [7:0] v_thresh_partial_vrg_ch3, // set threshold in vrg
    output logic [7:0] v_thresh_hold_vrg_ch3, // set threshold in vrg
    output logic [4:0] i_bias_fast_buffer,// bias current for fout buffers
    output logic [4:0] i_bias_total_int_csi_ch0,// delay bias for total int
    output logic [4:0] i_bias_partial_int_csi_ch0,// delay for partial int
    output logic [4:0] i_bias_hold_csi_ch0,// delay for hold line
    output logic [4:0] i_bias_total_int_csi_ch2,// delay bias for total int
    output logic [4:0] i_bias_partial_int_csi_ch2,// delay for partial int
    output logic [4:0] i_bias_hold_csi_ch2,// delay for hold line
    output logic [4:0] i_bias_total_int_vrg_ch1,// delay bias for total int
    output logic [4:0] i_bias_partial_int_vrg_ch1,// delay for partial int
    output logic [4:0] i_bias_hold_vrg_ch1,// delay for hold line
    output logic [4:0] i_bias_total_int_vrg_ch3,// delay bias for total int
    output logic [4:0] i_bias_partial_int_vrg_ch3,// delay for partial int
    output logic [4:0] i_bias_hold_vrg_ch3,// delay for hold line
    output logic [4:0] i_bias_hold_delay, // bias for hold line delay
    output logic [4:0] i_bias_disc_sout_delay, // delay for disc output
    output logic [4:0] i_bias_fout_width_trim, // std width trim
    output logic [4:0] i_bias_sout_comp_width, // std width trim
    output logic sel_std_sout_comp_width, // high for std width
    output logic [7:0] tunable_res_total_int, // adjust resistor value
    output logic [6:0] tunable_res_msbs, // adjust resistor value
    output logic [5:0] tunable_res_subtr_gain, // adjust resistor value
    output logic [2:0] tunable_res_rcg_gain, // adjust resistor value
    output logic [4:0] digital_testbus0_sel, // select signal to testbus0
    output logic digital_testbus0_pd, // pd testbus0
    output logic [4:0] digital_testbus1_sel, // select signal to testbus1
    output logic digital_testbus1_pd, // pd testbus1
    output logic [4:0] digital_testbus2_sel, // select signal to testbus2
    output logic digital_testbus2_pd, // pd testbus2
    output logic [4:0] digital_testbus3_sel, // select signal to testbus3
    output logic digital_testbus3_pd, // pd testbus3
    output logic [3:0] sout_comp_out_pd, // high to power down LVDS chan
    output logic lvds_rx_pd, // shared pd for LVDS inputs
    output logic lvds_high_cm, // use high LVDS cm if asserted
    output logic lvds_loopback_enable, // high to enable loopback
    output logic external_trigger_enable, // high to en ext trig
    output logic cross_trigger_enable, // high to en cross trig
    output logic [7:0] current_monitor, // measure internal currents
    output logic [7:0] voltage_monitor, // measure internal voltages
// SPARES
    output logic [7:0] spare0,  // 8 spare configuration bits
    output logic [7:0] spare1,  // 8 spare configuration bits
    output logic [7:0] spare2,  // 8 spare configuration bits
    output logic [7:0] spare3,  // 8 spare configuration bits
// INPUTS
    input logic posi,       // PRIMARY-OUT-SECONDARY-IN: RX UART input bit  
    input logic clk,        // clk for UART
    input logic reset_n);   // asynchronous reset for UART (active low)

`include "nanoCMOS_chip_constants.sv"
logic [7:0] config_bits [0:NUMREGS-1];// regmap config bit outputs

always_comb begin
    enable_channel = config_bits[CHANNEL_ENABLE][3:0];
    v_buff_ref_global = config_bits[BUFF_REF0][2:0];
    v_buff_ref_fine0 = config_bits[BUFF_REF1][7:0];
    v_buff_ref_fine1 = config_bits[BUFF_REF2][7:0];
    v_buff_ref_fine2 = config_bits[BUFF_REF3][7:0];
    v_buff_ref_fine3 = config_bits[BUFF_REF4][7:0];
    v_fine_refp = config_bits[FINE_REFP][7:0];
    v_fine_refn = config_bits[FINE_REFN][7:0];
    v_ref_comp0 = config_bits[D2S_REF0][7:0];
    v_ref_comp1 = config_bits[D2S_REF1][7:0];
    v_ref_comp2 = config_bits[D2S_REF2][7:0];
    v_ref_comp3 = config_bits[D2S_REF3][7:0];
    v_comp_thresh_sout_global = config_bits[THRESH_SOUT_GLOBAL][2:0];
    v_comp_thresh_sout_fine0 = config_bits[THRESH_SOUT_FINE0][7:0];
    v_comp_thresh_sout_fine1 = config_bits[THRESH_SOUT_FINE1][7:0];
    v_comp_thresh_sout_fine2 = config_bits[THRESH_SOUT_FINE2][7:0];
    v_comp_thresh_sout_fine3 = config_bits[THRESH_SOUT_FINE3][7:0];
    v_comp_thresh_fout_global = config_bits[THRESH_FOUT_GLOBAL][2:0];
    v_comp_thresh_fout_fine0 = config_bits[THRESH_FOUT_FINE0][7:0];
    v_comp_thresh_fout_fine1 = config_bits[THRESH_FOUT_FINE1][7:0];
    v_comp_thresh_fout_fine2 = config_bits[THRESH_FOUT_FINE2][7:0];
    v_comp_thresh_fout_fine3 = config_bits[THRESH_FOUT_FINE3][7:0];
    v_baseline_rcg_global = config_bits[BASELINE_RCG_GLOBAL][2:0];
    v_baseline_rcg_fine0 = config_bits[BASELINE_RCG_FINE0][7:0];
    v_baseline_rcg_fine1 = config_bits[BASELINE_RCG_FINE1][7:0];
    v_baseline_rcg_fine2 = config_bits[BASELINE_RCG_FINE2][7:0];
    v_baseline_rcg_fine3 = config_bits[BASELINE_RCG_FINE3][7:0];
    v_thresh_midpt_vrg = config_bits[THRESH_MIDPT_VRG][7:0];
    v_thresh_total_vrg_ch1 = config_bits[THRESH_TOTAL_VRG1][7:0]; 
    v_thresh_partial_vrg_ch1 = config_bits[THRESH_PARTIAL_VRG1][7:0]; 
    v_thresh_hold_vrg_ch1 = config_bits[THRESH_HOLD_VRG1][7:0]; 
    v_thresh_total_vrg_ch3 = config_bits[THRESH_TOTAL_VRG3][7:0];
    v_thresh_partial_vrg_ch3 = config_bits[THRESH_PARTIAL_VRG3][7:0]; 
    v_thresh_hold_vrg_ch3 = config_bits[THRESH_HOLD_VRG3][7:0]; 
    i_bias_fast_buffer = config_bits[IBIAS_FAST_BUFFER][4:0];
    i_bias_total_int_csi_ch0 = config_bits[IBIAS_TOTAL_INT_CSI_CH0][4:0];
    i_bias_partial_int_csi_ch0 = config_bits[IBIAS_PARTIAL_INT_CSI_CH0][4:0];
    i_bias_hold_csi_ch0 = config_bits[IBIAS_HOLD_CSI_CH0][4:0];
    i_bias_total_int_csi_ch2 = config_bits[IBIAS_TOTAL_INT_CSI_CH2][4:0];
    i_bias_partial_int_csi_ch2 = config_bits[IBIAS_PARTIAL_INT_CSI_CH2][4:0];
    i_bias_hold_csi_ch2 = config_bits[IBIAS_HOLD_CSI_CH2][4:0];
    i_bias_total_int_vrg_ch1 = config_bits[IBIAS_TOTAL_INT_VRG_CH1][4:0];
    i_bias_partial_int_vrg_ch1 = config_bits[IBIAS_PARTIAL_INT_VRG_CH1][4:0]; 
    i_bias_hold_vrg_ch1 = config_bits[IBIAS_HOLD_VRG_CH1][4:0]; 
    i_bias_total_int_vrg_ch3 = config_bits[IBIAS_TOTAL_INT_VRG_CH3][4:0]; 
    i_bias_partial_int_vrg_ch3 = config_bits[IBIAS_PARTIAL_INT_VRG_CH3][4:0];
    i_bias_hold_vrg_ch3 = config_bits[IBIAS_HOLD_VRG_CH3][4:0];
    i_bias_hold_delay = config_bits[IBIAS_HOLD_DELAY][4:0];
    i_bias_disc_sout_delay = config_bits[IBIAS_SOUT_DELAY][4:0];
    i_bias_fout_width_trim = config_bits[IBIAS_FOUT_WIDTH][4:0];
    i_bias_sout_comp_width = config_bits[IBIAS_SOUT_COMP_WIDTH][4:0];
    sel_std_sout_comp_width = config_bits[IBIAS_SOUT_COMP_WIDTH][4];
    tunable_res_total_int = config_bits[TUNABLE_RES_TOTAL_INT][7:0];
    tunable_res_msbs = config_bits[TUNABLE_RES_MSBS][6:0];
    tunable_res_subtr_gain = config_bits[TUNABLE_RES_SUBTR_GAIN][5:0];
    tunable_res_rcg_gain = config_bits[TUNABLE_RES_RCG_GAIN][4:0];
    digital_testbus0_sel = config_bits[DIGITAL_TESTBUS0][4:0];
    digital_testbus0_pd = config_bits[DIGITAL_TESTBUS0][5];
    digital_testbus1_sel = config_bits[DIGITAL_TESTBUS1][4:0];
    digital_testbus1_pd = config_bits[DIGITAL_TESTBUS1][5];
    digital_testbus2_sel = config_bits[DIGITAL_TESTBUS2][4:0];
    digital_testbus2_pd = config_bits[DIGITAL_TESTBUS2][5];
    digital_testbus3_sel = config_bits[DIGITAL_TESTBUS3][4:0];
    digital_testbus3_pd = config_bits[DIGITAL_TESTBUS3][5];
    sout_comp_out_pd = config_bits[LVDS][3:0];
    lvds_rx_pd = config_bits[LVDS][4];
    lvds_high_cm = config_bits[LVDS][5];
    lvds_loopback_enable = config_bits[LVDS][6];
    external_trigger_enable = config_bits[TRIGGER][0];
    cross_trigger_enable = config_bits[TRIGGER][1];
    current_monitor = config_bits[IMONITOR][7:0];
    voltage_monitor = config_bits[VMONITOR][7:0];
    spare0 = config_bits[SPARE0][7:0];
    spare1 = config_bits[SPARE1][7:0];
    spare2 = config_bits[SPARE2][7:0];
    spare3 = config_bits[SPARE3][7:0];
end // always_comb

external_interface
    #(.NUMREGS(NUMREGS)
    ) external_interface_inst (
    .config_bits            (config_bits),
    .piso                   (piso),
    .posi                   (posi),
    .clk                    (clk),
    .reset_n                (reset_n)
    );

endmodule
