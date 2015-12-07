/*
 * Robot.xc
 *
 *  Created on: Dec 6, 2015
 *      Author: terry
 */

#include <xs1.h>
#include <timer.h>
#include <stdio.h>
#include <i2c.h>
#include <platform.h>

on tile[0] : port p_scl = XS1_PORT_1C;
on tile[0] : port p_sda = XS1_PORT_1D;

uint16_t read_reg_16(client interface i2c_master_if i2c,
        uint8_t device_addr, uint8_t func_code, uint16_t reg, uint16_t num_of_reg_to_read,
        i2c_regop_res_t &result) {
    uint16_t read_data = 0x0000;
    uint8_t a_reg[5] = {
            func_code,
            (reg & 0xff00) >> 8,
            (reg & 0x00ff) >> 0,
            (num_of_reg_to_read & 0xff00) >> 8,
            (num_of_reg_to_read & 0x00ff) >> 0,
    };
    uint8_t data[4] = {0, 0, 0, 0};
    size_t n;
    i2c_res_t res;
    res = i2c.write(device_addr, a_reg, 5, n, 0);
    printf("n = %d\n", n);
    if (n != 5) {
        result = I2C_REGOP_DEVICE_NACK;
        i2c.send_stop_bit();
        return read_data;
    }
    res = i2c.read(device_addr, data, 2, 1);
    if (res == I2C_NACK) {
        result = I2C_REGOP_DEVICE_NACK;
    } else {
        result = I2C_REGOP_SUCCESS;
    }
    read_data = ((data[3] << 8) & 0xff00) | ((data[2] << 0) & 0x00ff);
    return read_data;
}

void i2c_control_init(server interface i2c_master_if i2c[n], size_t n)
{
    printf("i2c_control_init\n");
    i2c_master(i2c, n, p_scl, p_sda, 100);
}

void i2c_control_run(client interface i2c_master_if i2c)
{
    printf("i2c_control_run\n");
    uint16_t value;
    uint8_t device_addr = 0x15;
    uint16_t reg = 0x1389;
    i2c_regop_res_t result;
    value = read_reg_16(i2c, device_addr, 0x04, reg, 0x0001, result);
    printf("%04x\n", value);
}

int main(void) {
    i2c_master_if i_i2c[1];
    par {
        on tile[0] : i2c_control_init(i_i2c, 1);
        on tile[0] : i2c_control_run(i_i2c[0]);
    }
    return 0;
}
