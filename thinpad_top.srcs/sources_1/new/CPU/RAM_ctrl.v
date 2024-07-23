`include "Header.vh"

module RAM_ctrl (
    input wire clk_50M,
    input wire rst,

    output reg  [31:0] inst_sram_rdata,
    input  wire        inst_sram_ce,
    input  wire [31:0] inst_sram_addr,

    output reg  [31:0] data_sram_rdata,
    input  wire        data_sram_ce,
    input  wire        data_sram_we,
    input  wire [3:0]  data_sram_be,
    input  wire [31:0] data_sram_addr,
    input  wire [31:0] data_sram_wdata,

    input  wire txd, // 串口发送端
    output wire rxd, // 串口接收端

    // BaseRAM 信号
    inout  wire [31:0] base_ram_data, // BaseRAM 数据，低 8 位与 CPLD 串口控制器共享
    output reg  [19:0] base_ram_addr, // BaseRAM 地址
    output reg  [3:0]  base_ram_be_n, // BaseRAM 字节使能，低有效。如果不使用字节使能，请保持为 0
    output reg         base_ram_ce_n, // BaseRAM 片选，低有效
    output reg         base_ram_oe_n, // BaseRAM 读使能，低有效
    output reg         base_ram_we_n, // BaseRAM 写使能，低有效

    // ExtRAM 信号
    inout  wire [31:0] ext_ram_data, // ExtRAM 数据
    output reg  [19:0] ext_ram_addr, // ExtRAM 地址
    output reg  [3:0]  ext_ram_be_n, // ExtRAM 字节使能，低有效。如果不使用字节使能，请保持为 0
    output reg         ext_ram_ce_n, // ExtRAM 片选，低有效
    output reg         ext_ram_oe_n, // ExtRAM 读使能，低有效
    output reg         ext_ram_we_n  // ExtRAM 写使能，低有效
);

    wire [7:0] ext_uart_rx;
    reg  [7:0] ext_uart_tx;
    wire ext_uart_ready, ext_uart_busy;
    reg  ext_uart_start, ext_uart_clear, ext_uart_clear_next;

    // 接收模块，9600 无检验位
    async_receiver #(.ClkFrequency(50000000),.Baud(9600))
        ext_uart_r(
            .clk(clk_50M),                       //外部时钟信号
            .RxD(rxd),                           //外部串行信号输入
            .RxD_data_ready(ext_uart_ready),  //数据接收到标志
            .RxD_clear(ext_uart_clear),       //清除接收标志
            .RxD_data(ext_uart_rx)             //接收到的一字节数据
        );

    // 发送模块，9600 无检验位
    async_transmitter #(.ClkFrequency(50000000),.Baud(9600))
        ext_uart_t(
            .clk(clk_50M),                  //外部时钟信号
            .TxD(txd),                      //串行信号输出
            .TxD_busy(ext_uart_busy),       //发送器忙状态指示
            .TxD_start(ext_uart_start),    //开始发送信号
            .TxD_data(ext_uart_tx)        //待发送的数据
        );

    wire is_serial_stat = (data_sram_addr == `SERIAL_STAT);
    wire is_serial_data = (data_sram_addr == `SERIAL_DATA);
    wire is_base_ram = !is_serial_stat && !is_serial_data && (data_sram_addr >= `BASE_ADDR_ST && data_sram_addr < `BASE_ADDR_ED);
    wire is_ext_ram = !is_serial_stat && !is_serial_data && (data_sram_addr >= `EXT_ADDR_ST && data_sram_addr < `EXT_ADDR_ED);

    reg [31:0] serial_data;

    // 串口
    always @(*) begin
        if (rst) begin
            ext_uart_start = 1'b0;
            ext_uart_tx = 8'b0;
            serial_data = 32'b0;
        end else begin
            if (is_serial_stat) begin
                ext_uart_start = 1'b0;
                ext_uart_tx = 8'b0;
                serial_data = {{30'b0}, {ext_uart_ready}, {!ext_uart_busy}};
            end else if (data_sram_addr == `SERIAL_DATA) begin
                if (data_sram_we) begin
                    ext_uart_start = 1'b0;
                    ext_uart_tx = 8'b0;
                    serial_data = {24'b0, ext_uart_rx};
                end else begin
                    ext_uart_start = 1'b1;
                    ext_uart_tx = data_sram_wdata[7:0];
                    serial_data = 32'b0;
                end
            end else begin
                ext_uart_start = 1'b0;
                ext_uart_tx = 8'b0;
                serial_data = 32'b0;
            end
        end
    end

    // uart clear
    always @(posedge clk_50M) begin
        if (rst) begin
            ext_uart_clear <= 1'b0;
        end else begin
            if (ext_uart_clear_next) begin
                ext_uart_clear <= 1'b1;
            end else begin
                ext_uart_clear <= 1'b0;
            end
        end
    end

    // next uart clear
    always @(negedge clk_50M) begin
        if (rst) begin
            ext_uart_clear_next <= 1'b0;
        end else begin
            if (ext_uart_busy && data_sram_we && data_sram_addr == `SERIAL_DATA && !ext_uart_clear_next) begin
                ext_uart_clear_next <= 1'b1;
            end else if (ext_uart_clear) begin
                ext_uart_clear_next <= 1'b0;
            end else begin
                ext_uart_clear_next <= ext_uart_clear_next;
            end
        end
    end

    assign base_ram_data = is_base_ram ? (data_sram_we ? 32'hzzzzzzzz : data_sram_wdata) : 32'hzzzzzzzz;
    wire [31:0] base_ram_out = base_ram_data;

    // BaseRAM
    always @(*) begin
        if (rst) begin
            base_ram_addr = 20'b0;
            base_ram_be_n = 4'b1111;
            base_ram_ce_n = 1'b1;
            base_ram_oe_n = 1'b1;
            base_ram_we_n = 1'b1;
            inst_sram_rdata = 32'b0;
        end else begin
            if (is_base_ram) begin
                base_ram_addr = data_sram_addr[21:2];
                base_ram_be_n = data_sram_be;
                base_ram_ce_n = 1'b0;
                base_ram_oe_n = !data_sram_we;
                base_ram_we_n = data_sram_we;
            end else begin
                base_ram_addr = inst_sram_addr[21:2];
                base_ram_be_n = 4'b0;
                base_ram_ce_n = 1'b0;
                base_ram_oe_n = 1'b0;
                base_ram_we_n = 1'b1;
            end
            inst_sram_rdata = base_ram_out;
        end
    end

    assign ext_ram_data = data_sram_we ? 32'hzzzzzzzz : data_sram_wdata;
    wire [31:0] ext_ram_out = ext_ram_data;

    // ExtRAM
    always @(*) begin
        if (rst) begin
            ext_ram_addr = 20'b0;
            ext_ram_be_n = 4'b1111;
            ext_ram_ce_n = 1'b1;
            ext_ram_oe_n = 1'b1;
            ext_ram_we_n = 1'b1;
        end else begin
            if (is_ext_ram) begin
                ext_ram_addr = data_sram_addr[21:2];
                ext_ram_be_n = data_sram_be;
                ext_ram_ce_n = 1'b0;
                ext_ram_oe_n = !data_sram_we;
                ext_ram_we_n = data_sram_we;
            end else begin
                ext_ram_addr = 20'b0;
                ext_ram_be_n = 4'b0;
                ext_ram_ce_n = 1'b0;
                ext_ram_oe_n = 1'b0;
                ext_ram_we_n = 1'b1;
            end
        end
    end

    always @(*) begin
        if (rst) begin
            data_sram_rdata = 32'b0;
        end else if (is_base_ram) begin
            case (data_sram_be)
                4'b1110: data_sram_rdata = {{24{base_ram_out[7]}}, base_ram_out[7:0]};
                4'b1101: data_sram_rdata = {{24{base_ram_out[15]}}, base_ram_out[15:8]};
                4'b1011: data_sram_rdata = {{24{base_ram_out[23]}}, base_ram_out[23:16]};
                4'b0111: data_sram_rdata = {{24{base_ram_out[31]}}, base_ram_out[31:24]};
                4'b0000: data_sram_rdata = base_ram_out;
                default: data_sram_rdata = 32'b0;
            endcase
        end else if (is_ext_ram) begin
            case (data_sram_be)
                4'b1110: data_sram_rdata = {{24{ext_ram_out[7]}}, ext_ram_out[7:0]};
                4'b1101: data_sram_rdata = {{24{ext_ram_out[15]}}, ext_ram_out[15:8]};
                4'b1011: data_sram_rdata = {{24{ext_ram_out[23]}}, ext_ram_out[23:16]};
                4'b0111: data_sram_rdata = {{24{ext_ram_out[31]}}, ext_ram_out[31:24]};
                4'b0000: data_sram_rdata = ext_ram_out;
                default: data_sram_rdata = 32'b0;
            endcase
        end else begin
            data_sram_rdata = 32'b0;
        end
    end

endmodule