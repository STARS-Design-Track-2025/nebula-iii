`default_nettype none

module t02_sensor_decoder(
    input logic [79:0] data_out,
    output logic [15:0] accel_x, accel_y, accel_z, gyro_x, gyro_y
);

    assign accel_x = data_out[79:64];
    assign accel_y = data_out[63:48];
    assign accel_z = data_out[47:32];
    assign gyro_x = data_out[31:16];
    assign gyro_y = data_out[15:0];


endmodule