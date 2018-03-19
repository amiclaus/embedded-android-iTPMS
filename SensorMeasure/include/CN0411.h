/***************************************************************************//**
 *   @file   CN0411.h
 *   @brief  CN0411 header file
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
#ifndef _CN0411_H_
#define _CN0411_H_

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/

#include "AD7124.h"
#include "AD5683.h"

/******************************************************************************/
/********************** Macros and Constants Definitions **********************/
/******************************************************************************/

#define CN0411_SUCCESS 0
#define CN0411_FAILURE -1
#define CS_AD7124 0
#define CS_AD5683 1
#define ADC_TIMEOUT 10000
#define ADC_CH_DISABLE 0
#define ADC_CH_ENABLE 1
#define ADC_CH0 0
#define ADC_CH1 1
#define ADC_CH2 2
#define ADC_CONTINUOUS_CONV 1
#define ADC_SINGLE_CONV 2
#define ADC_CH_RDY_MSK 0x8F
#define PWM_SYSCALIB_AIN7 1
#define PWM_SYSCALIB_AIN8 2
#define PWM_CONVERSION 3
#define PWM_FREQ_300 300
#define PWM_FREQ_2400 2400
#define DAC_FS_VAL 0xFFFF
#define MUX_DEFAULT_CH 6
#define DAC_OUT_DEFAULT_VAL 0.2
#define EXC_DEFAULT_VAL 0
#define RES_GAIN_DEFAULT_CH 6
#define VREFIN (0.250 * 4.02)
#define OFFSET_RES_INIT 0
#define PREC_REF_RES 1500
#define RTD_REF_RES 4020
#define RTD_RES_100 100
#define RTD_RES_1K 1000
#define TCAL 25
#define CELL_CONST_LOW 0.1
#define CELL_CONST_NORMAL 1
#define CELL_CONST_HIGH 10
#define TDS_KCL 0.5
#define TDS_NACL 0.47
#define TEMP_COEFF_KCL 1.88
#define TEMP_COEFF_NACL 2.14
#define VREF 2.5
#define A (3.9083*pow(10,-3))
#define B (-5.775*pow(10,-7))

/******************************************************************************/
/************************** Variable Declaration ******************************/
/******************************************************************************/

typedef struct cn0411_device cn0411_device;
typedef struct solution solution;

uint8_t pwm_status;
int pwm_tick_count;
uint16_t pwm_step;
uint16_t pwm2_high;
uint16_t pwm2_low;
uint16_t pwm0_high;
uint16_t pwm1_high;
uint16_t pwm1_low;
uint16_t pwm0_low;

struct solution {
	float temp_coeff;
	float tds_factor;
};

struct cn0411_device {
	uint8_t ch_gain;
	uint8_t conv_type;
	uint16_t rtd_res;
	uint32_t r_gain[7];
	float offset_res;
	float v_dac;
	float v_exc;
	float cell_const;
	solution solution;
	ad7124_device ad7124_dev;
	ad5683_device ad5683_dev;
};

typedef  void (*cmd_func)(uint8_t *, cn0411_device *);

/******************************************************************************/
/************************** Function Declaration ******************************/
/******************************************************************************/

int32_t CN0411_DAC_set_value(cn0411_device *cn0411_dev, float output_val);
int32_t CN0411_ADC_operation_mode (cn0411_device *cn0411_dev, opMode mode);
int32_t CN0411_ADC_setup0 (cn0411_device *cn0411_dev);
int32_t CN0411_ADC_setup1 (cn0411_device *cn0411_dev);
int32_t CN0411_ADC_set_ch0 (cn0411_device *cn0411_dev, uint8_t ch_en);
int32_t CN0411_ADC_set_ch1 (cn0411_device *cn0411_dev, uint8_t ch_en);
int32_t CN0411_ADC_set_ch2 (cn0411_device *cn0411_dev, uint8_t ch_en);
int32_t CN0411_ADC_set_io1 (cn0411_device *cn0411_dev, uint8_t ch_gain);
int32_t CN0411_ADC_set_io2 (cn0411_device *cn0411_dev);
int32_t CN0411_ADC_conv_init(cn0411_device *cn0411_dev, uint8_t conv_mod);
int32_t CN0411_read_temp(cn0411_device *cn0411_dev, float *temp);
int32_t CN0411_read_vpp(cn0411_device *cn0411_dev, float *vpp);
int32_t CN0411_compute_cond(cn0411_device *cn0411_dev, float *cond);
int32_t CN0411_compute_off_res(cn0411_device *cn0411_dev);
int32_t CN0411_compensate_cond(cn0411_device *cn0411_dev, float *comp_cond);
int32_t CN0411_compute_tds(cn0411_device *cn0411_dev, float *tds);
int32_t CN0411_ADC_int_calibrate(cn0411_device *cn0411_dev);
int32_t CN0411_ADC_sys_calibrate(cn0411_device *cn0411_dev);
int32_t CN0411_premeasurement(cn0411_device *cn0411_dev);
cmd_func CN0411_find_command(char *cmd);
void CN0411_cmd_process(cn0411_device *cn0411_dev);
int32_t CN0411_cmd_prompt(void);
uint8_t *CN0326_find_argv(uint8_t *args);
void CN0326_get_argv(char *dst, uint8_t *args);
void CN0411_cmd_help(uint8_t *args, cn0411_device *cn0411_dev);
void CN0411_cmd_sys_calib(uint8_t *args, cn0411_device *cn0411_dev);
void CN0411_cmd_off_res(uint8_t *args, cn0411_device *cn0411_dev);
void CN0411_cmd_conv_mode(uint8_t *args, cn0411_device *cn0411_dev);
void CN0411_cmd_dac_val(uint8_t *args, cn0411_device *cn0411_dev);
void CN0411_cmd_rtd_val(uint8_t *args,cn0411_device *cn0411_dev);
void CN0411_cmd_pwm_freq(uint8_t *args, cn0411_device *cn0411_dev);
void CN0411_cmd_cell_const(uint8_t *args, cn0411_device *cn0411_dev);
void CN0411_cmd_solution(uint8_t *args, cn0411_device *cn0411_dev);
void CN0411_cmd_temp(uint8_t *args, cn0411_device *cn0411_dev);
void CN0411_cmd_cond(uint8_t *args, cn0411_device *cn0411_dev);
void CN0411_cmd_tds(uint8_t *args, cn0411_device *cn0411_dev);
void CN0411_interrupt(void);
void CN0411_pwm_freq(uint16_t freq);
void CN0411_pwm_gen(void);
int32_t CN0411_init(cn0411_device *cn0411_dev);

#endif /* _CN0411_H_ */
