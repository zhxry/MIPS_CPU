`define SERIAL_STAT 32'hBFD003FC
`define SERIAL_DATA 32'hBFD003F8

`define BASE_ADDR_ST 32'h80000000
`define BASE_ADDR_ED 32'h80400000
`define EXT_ADDR_ST  32'h80400000
`define EXT_ADDR_ED  32'h80800000

module RAM_Serial_Ctrl (
    input wire clk,
    input wire rst,

    input  wire [31:0] inst_sram_addr,
    input  wire        inst_sram_ce,
    output reg  [31:0] inst_sram_rdata,

    output reg  [31:0] data_sram_rdata,
    input  wire        data_sram_ce,
    input  wire        data_sram_we,
    input  wire [3:0]  data_sram_be,
    input  wire [31:0] data_sram_addr,
    input  wire [31:0] data_sram_wdata,

    output wire txd, // 串口发送端
    input  wire rxd, // 串口接收端

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
    output reg         ext_ram_we_n, // ExtRAM 写使能，低有效

    output wire [1:0] state
);

    wire       RxD_data_ready;
    wire       RxD_clear;
    wire [7:0] RxD_data;
    wire       TxD_busy;
    wire       TxD_start;
    wire [7:0] TxD_data;
    // reg  TxD_start, RxD_clear, RxD_clear_next;

    // 接收模块，9600 无检验位
    async_receiver #(.ClkFrequency(59000000),.Baud(9600))
        ext_uart_r(
            .clk(clk),                       //外部时钟信号
            .RxD(rxd),                           //外部串行信号输入
            .RxD_data_ready(RxD_data_ready),  //数据接收到标志
            .RxD_clear(RxD_clear),       //清除接收标志
            .RxD_data(RxD_data)             //接收到的一字节数据
        );

    // 发送模块，9600 无检验位
    async_transmitter #(.ClkFrequency(59000000),.Baud(9600))
        ext_uart_t(
            .clk(clk),                  //外部时钟信号
            .TxD(txd),                      //串行信号输出
            .TxD_busy(TxD_busy),       //发送器忙状态指示
            .TxD_start(TxD_start),    //开始发送信号
            .TxD_data(TxD_data)        //待发送的数据
        );

    wire is_serial_stat = (data_sram_addr == `SERIAL_STAT);
    wire is_serial_data = (data_sram_addr == `SERIAL_DATA);
    wire is_base_ram = (data_sram_addr >= `BASE_ADDR_ST) && (data_sram_addr < `BASE_ADDR_ED);
    wire is_ext_ram = (data_sram_addr >= `EXT_ADDR_ST) && (data_sram_addr < `EXT_ADDR_ED);
    // wire is_base_ram = !is_serial_stat && !is_serial_data && (data_sram_addr >= `BASE_ADDR_ST && data_sram_addr < `BASE_ADDR_ED);
    // wire is_ext_ram = !is_serial_stat && !is_serial_data && (data_sram_addr >= `EXT_ADDR_ST && data_sram_addr < `EXT_ADDR_ED);

    reg [31:0] serial_o;
    wire       RxD_FIFO_wr_en;
    wire       RxD_FIFO_full;
    wire [7:0] RxD_FIFO_din;
    reg        RxD_FIFO_rd_en;
    wire       RxD_FIFO_empty;
    wire [7:0] RxD_FIFO_dout;
    reg        TxD_FIFO_wr_en;
    wire       TxD_FIFO_full;
    reg  [7:0] TxD_FIFO_din;
    wire       TxD_FIFO_rd_en;
    wire       TxD_FIFO_empty;
    wire [7:0] TxD_FIFO_dout;

    fifo_generator_0 RxD_FIFO (
        .rst(rst),
        .clk(clk),
        .wr_en(RxD_FIFO_wr_en),     //写使能
        .din(RxD_FIFO_din),         //接收到的数据
        .full(RxD_FIFO_full),       //判满标志
        .rd_en(RxD_FIFO_rd_en),     //读使能
        .dout(RxD_FIFO_dout),       //传递给mem阶段读出的数据
        .empty(RxD_FIFO_empty)      //判空标志
    );

    fifo_generator_0 TxD_FIFO (
        .rst(rst),
        .clk(clk),
        .wr_en(TxD_FIFO_wr_en),     //写使能
        .din(TxD_FIFO_din),         //待发送的数据
        .full(TxD_FIFO_full),       //判满标志
        .rd_en(TxD_FIFO_rd_en),     //读使能
        .dout(TxD_FIFO_dout),       //发送器读出的数据
        .empty(TxD_FIFO_empty)      //判空标志
    );

    assign TxD_FIFO_rd_en = TxD_start;
    assign TxD_start = (!TxD_busy) && (!TxD_FIFO_empty);
    assign TxD_data = TxD_FIFO_dout;

    assign RxD_FIFO_wr_en = RxD_data_ready;
    assign RxD_FIFO_din = RxD_data;
    assign RxD_clear = RxD_data_ready && (!RxD_FIFO_full);

    // 串口
    always @(*) begin
        TxD_FIFO_wr_en = 1'b0;
        TxD_FIFO_din = 8'b0;
        RxD_FIFO_rd_en = 1'b0;
        serial_o = 32'b0;
        if (is_serial_stat) begin
            TxD_FIFO_wr_en = 1'b0;
            TxD_FIFO_din = 8'b0;
            RxD_FIFO_rd_en = 1'b0;
            serial_o = {{30{1'b0}}, {!RxD_FIFO_empty}, {!TxD_FIFO_full}};
        end else if (is_serial_data) begin
            if (data_sram_we) begin
                TxD_FIFO_wr_en = 1'b0;
                TxD_FIFO_din = 8'b0;
                RxD_FIFO_rd_en = 1'b1;
                serial_o = {{24{1'b0}}, RxD_FIFO_dout};
            end else begin
                TxD_FIFO_wr_en = 1'b1;
                TxD_FIFO_din = data_sram_wdata[7:0];
                RxD_FIFO_rd_en = 1'b0;
                serial_o = 32'b0;
            end
        end else begin
            TxD_FIFO_wr_en = 1'b0;
            TxD_FIFO_din = 8'b0;
            RxD_FIFO_rd_en = 1'b0;
            serial_o = 32'b0;
        end
    end

    assign base_ram_data = is_base_ram ? (data_sram_we ? 32'hzzzzzzzz : data_sram_wdata) : 32'hzzzzzzzz;
    wire [31:0] base_ram_out = base_ram_data;

    // BaseRAM
    always @(*) begin
        base_ram_addr = 20'b0;
        base_ram_be_n = 4'b1111;
        base_ram_ce_n = 1'b1;
        base_ram_oe_n = 1'b1;
        base_ram_we_n = 1'b1;
        inst_sram_rdata = 32'b0;
        if (is_base_ram) begin
            base_ram_addr = data_sram_addr[21:2];
            base_ram_be_n = data_sram_be;
            base_ram_ce_n = 1'b0;
            base_ram_oe_n = !data_sram_we;
            base_ram_we_n = data_sram_we;
            inst_sram_rdata = 32'b0;
        end else begin
            base_ram_addr = inst_sram_addr[21:2];
            base_ram_be_n = 4'b0;
            base_ram_ce_n = 1'b0;
            base_ram_oe_n = 1'b0;
            base_ram_we_n = 1'b1;
            inst_sram_rdata = base_ram_out;
        end
    end

    assign ext_ram_data = is_ext_ram ? (data_sram_we ? 32'hzzzzzzzz : data_sram_wdata) : 32'hzzzzzzzz;
    wire [31:0] ext_ram_out = ext_ram_data;

    // ExtRAM
    always @(*) begin
        ext_ram_addr = 20'h00000;
        ext_ram_be_n = 4'b0000;
        ext_ram_ce_n = 1'b0;
        ext_ram_oe_n = 1'b1;
        ext_ram_we_n = 1'b1;
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
            ext_ram_oe_n = 1'b1;
            ext_ram_we_n = 1'b1;
        end
    end

    always @(*) begin
        data_sram_rdata = 32'b0;
        if (is_serial_data || is_serial_stat) begin
            data_sram_rdata = serial_o;
        end else if (is_base_ram) begin
            case (data_sram_be)
                4'b1110: data_sram_rdata = {{24{base_ram_out[7]}}, base_ram_out[7:0]};
                4'b1101: data_sram_rdata = {{24{base_ram_out[15]}}, base_ram_out[15:8]};
                4'b1011: data_sram_rdata = {{24{base_ram_out[23]}}, base_ram_out[23:16]};
                4'b0111: data_sram_rdata = {{24{base_ram_out[31]}}, base_ram_out[31:24]};
                4'b0000: data_sram_rdata = base_ram_out;
                default: data_sram_rdata = base_ram_out;
            endcase
        end else if (is_ext_ram) begin
            case (data_sram_be)
                4'b1110: data_sram_rdata = {{24{ext_ram_out[7]}}, ext_ram_out[7:0]};
                4'b1101: data_sram_rdata = {{24{ext_ram_out[15]}}, ext_ram_out[15:8]};
                4'b1011: data_sram_rdata = {{24{ext_ram_out[23]}}, ext_ram_out[23:16]};
                4'b0111: data_sram_rdata = {{24{ext_ram_out[31]}}, ext_ram_out[31:24]};
                4'b0000: data_sram_rdata = ext_ram_out;
                default: data_sram_rdata = ext_ram_out;
            endcase
        end else begin
            data_sram_rdata = 32'b0;
        end
    end

endmodule