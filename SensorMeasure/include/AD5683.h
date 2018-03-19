/***************************************************************************//**
 *   @file   ad5683.h
 *   @brief  AD4110 Driver header file.
 *   @author Antoniu Miclaus (antoniu.miclaus@analog.com)
********************************************************************************
 * Copyright 2018(c) Analog Devices, Inc.
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *  - Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *  - Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *  - Neither the name of Analog Devices, Inc. nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *  - The use of this software may or may not infringe the patent rights
 *    of one or more patent holders.  This license does not release you
 *    from the requirement that you obtain separate licenses from these
 *    patent holders to use this software.
 *  - Use of the software either in source or binary form, must be run
 *    on or directly connected to an Analog Devices Inc. component.
 *
 * THIS SOFTWARE IS PROVIDED BY ANALOG DEVICES "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, NON-INFRINGEMENT,
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL ANALOG DEVICES BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, INTELLECTUAL PROPERTY RIGHTS, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*******************************************************************************/

#ifndef _AD5683_H_
#define _AD5683_H_

/******************************************************************************/
/********************** Macros and Constants Definitions **********************/
/******************************************************************************/

#define AD5683_CMD_NOP					0x0     // No operation.
#define AD5683_CMD_WR_IN_REG			0x1 	// Write Input Register.
#define AD5683_CMD_WR_DAC_REG           0x2 	// Update DAC Register.
#define AD5683_CMD_WR_DAC_IN_REG     	0x3		// Write DAC and Input Register.
#define AD5683_CMD_WR_CTRL_REG			0x4 	// Write Control Register.
#define AD5683_CMD_RB_IN_REG			0x5		// Readback input register.

/*************************** Write Control Register Bits **********************/

#define AD5683_DCEN(x)					(((((x) & 0x1) << 0) << 10) & 0xFC00)
#define AD5683_CFG_GAIN(x)				(((((x) & 0x1) << 1) << 10) & 0xFC00)
#define AD5683_REF_EN(x)				(((((x) & 0x1) << 2) << 10) & 0xFC00)
#define AD5683_OP_MOD(x)				(((((x) & 0x3) << 3) << 10) & 0xFC00)
#define AD5683_SW_RESET(x)				(((((x) & 0x1) << 5) << 10) & 0xFC00)

/******************************************************************************/
/**************************** Variable Declarations ***************************/
/******************************************************************************/
typedef struct {
	int slave_select_id;
	uint32_t dac_reg_value;
} ad5683_device;

typedef enum {
	AD5683_DC_DISABLE,
	AD5683_DC_ENABLE
} ad5683_state;

typedef enum {
	AD5683_INT_REF_ON,
	AD5683_INT_REF_OFF
} ad5683_voltage_ref;

typedef enum {
	AD5683_AMP_GAIN_1,
	AD5683_AMP_GAIN_2
} ad5683_amp_gain;

typedef enum {
	AD5683_PWR_NORMAL,
	AD5683_PD_1K,
	AD5683_PD_100K,
	AD5683_PD_3STATE
} ad5683_power_mode;

typedef enum {
	AD5683_RESET_DISABLE,
	AD5683_RESET_ENABLE
} ad5683_reset;

/******************************************************************************/
/**************************** Function Declarations ***************************/
/******************************************************************************/

int32_t AD5683_write_cmd(ad5683_device *device, uint8_t cmd, uint16_t data);

int32_t AD5683_readback_register(ad5683_device *device, uint32_t *data);

int32_t AD5683_write_dac_value(ad5683_device *device, uint16_t data);

int32_t AD5683_soft_reset(ad5683_device *device);

int32_t AD5683_setup(ad5683_device *device, int slave_select_id);

#endif /* _AD5683_H_ */
