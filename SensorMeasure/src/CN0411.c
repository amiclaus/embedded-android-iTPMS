/***************************************************************************//**
 *   @file   CN0411.c
 *   @brief  CN0411 source file
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

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/

#include <UrtLib.h>
#include <PwmLib.h>
#include "Timer.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <string.h>
#include "DioLib.h"
#include "math.h"
#include "Communication.h"
#include "CN0411.h"
#include "AD7124_regs.h"

/******************************************************************************/
/*************************** Variable Definitions *****************************/
/******************************************************************************/

/* Available commands */
char *cmd_commands[] = {
	"help",
	"syscal",
	"refres",
	"convmod",
	"dacval",
	"rtdval",
	"pwmfreq",
	"cellconst",
	"solution",
	"temp",
	"cond",
	"tds"
};

/* Functions for available commands */
cmd_func cmd_fun[] = {
	CN0411_cmd_help,
	CN0411_cmd_sys_calib,
	CN0411_cmd_off_res,
	CN0411_cmd_conv_mode,
	CN0411_cmd_dac_val,
	CN0411_cmd_rtd_val,
	CN0411_cmd_pwm_freq,
	CN0411_cmd_cell_const,
	CN0411_cmd_solution,
	CN0411_cmd_temp,
	CN0411_cmd_cond,
	CN0411_cmd_tds,
	NULL
};

/******************************************************************************/
/************************* Function Definitions *******************************/
/******************************************************************************/

/**
 * AD5683 set DAC output value
 *
 * @param cn0411_dev - The device structure.
 * @param output_val - voltage value to be written on DAC
 * @return 0 in case of success, negative error code otherwise.
*/
int32_t CN0411_DAC_set_value(cn0411_device *cn0411_dev, float output_val)
{
	int32_t ret;
	uint32_t dac_val;

	dac_val = (uint32_t)(output_val * DAC_FS_VAL / VREF);
	cn0411_dev->ad5683_dev.dac_reg_value = dac_val;
	ret = AD5683_write_dac_value(&cn0411_dev->ad5683_dev,
				     cn0411_dev->ad5683_dev.dac_reg_value);

	return ret;
}

/**
 * AD7124 Operation Mode function
 *
 * @param cn0411_dev - The device structure.
 * @param mode - operation mode of the ADC
 * @return 0 in case of success, negative error code otherwise.
*/
int32_t CN0411_ADC_operation_mode (cn0411_device * cn0411_dev, opMode mode)
{
	int32_t ret;

	cn0411_dev->ad7124_dev.regs[AD7124_ADC_Control].value =
		(AD7124_ADC_CTRL_REG_REF_EN
		 | AD7124_ADC_CTRL_REG_DATA_STATUS
		 | AD7124_ADC_CTRL_REG_POWER_MODE(LOW_POWER)
		 | AD7124_ADC_CTRL_REG_MODE(mode)
		 | AD7124_ADC_CTRL_REG_CLK_SEL(INTERNAL_CLK1));

	ret = AD7124_WriteRegister(&cn0411_dev->ad7124_dev,
				   cn0411_dev->ad7124_dev.regs[AD7124_ADC_Control]);

	return ret;
}

/**
 * AD7124 Setup 0 configuration function
 *
 * @param cn0411_dev - The device structure.
 * @return 0 in case of success, negative error code otherwise.
*/
int32_t CN0411_ADC_setup0 (cn0411_device *cn0411_dev)
{
	int32_t ret;

	cn0411_dev->ad7124_dev.regs[AD7124_Config_0].value =
		(AD7124_CFG_REG_BURNOUT(0) | AD7124_CFG_REG_REF_BUFP
		 | AD7124_CFG_REG_REF_BUFM | AD7124_CFG_REG_AIN_BUFP
		 | AD7124_CFG_REG_AINN_BUFM | AD7124_CFG_REG_REF_SEL(0)
		 | AD7124_CFG_REG_PGA(0));

	ret = AD7124_WriteRegister(&cn0411_dev->ad7124_dev,
				   cn0411_dev->ad7124_dev.regs[AD7124_Config_0]);
	ret = AD7124_ReadRegister(&cn0411_dev->ad7124_dev,
				  &cn0411_dev->ad7124_dev.regs[AD7124_Config_0]);
	ret = AD7124_WriteRegister(&cn0411_dev->ad7124_dev,
				   cn0411_dev->ad7124_dev.regs[AD7124_Config_0]);

	return ret;
}

/**
 * AD7124 Setup 1 configuration function
 *
 * @param cn0411_dev - The device structure.
 * @return 0 in case of success, negative error code otherwise.
*/
int32_t CN0411_ADC_setup1 (cn0411_device *cn0411_dev)
{
	int32_t ret;

	cn0411_dev->ad7124_dev.regs[AD7124_Config_1].value =
		(AD7124_CFG_REG_BURNOUT(0)
		 | AD7124_CFG_REG_REF_BUFP
		 | AD7124_CFG_REG_REF_BUFM
		 | AD7124_CFG_REG_AIN_BUFP
		 | AD7124_CFG_REG_AINN_BUFM
		 | AD7124_CFG_REG_REF_SEL(2)
		 | AD7124_CFG_REG_PGA(0));
	ret = AD7124_WriteRegister(&cn0411_dev->ad7124_dev,
				   cn0411_dev->ad7124_dev.regs[AD7124_Config_1]);

	return ret;
}

/**
 * AD7124 Channel 0 configuration function
 *
 * @param cn0411_dev - The device structure.
 * @param ch_en - enable/disable ADC channel
 * @return 0 in case of success, negative error code otherwise.
*/
int32_t CN0411_ADC_ch0 (cn0411_device *cn0411_dev, uint8_t ch_en)
{
	int32_t ret;

	cn0411_dev->ad7124_dev.regs[AD7124_Channel_0].value = ((ch_en << 15)
			| AD7124_CH_MAP_REG_SETUP(0)
			| AD7124_CH_MAP_REG_AINP(1)
			| AD7124_CH_MAP_REG_AINM(6));
	ret = AD7124_WriteRegister(&cn0411_dev->ad7124_dev,
				   cn0411_dev->ad7124_dev.regs[AD7124_Channel_0]);

	return ret;
}

/**
 * AD7124 Channel 1 configuration function
 *
 * @param cn0411_dev - The device structure.
 * @param ch_en - enable/disable ADC channel
 * @return 0 in case of success, negative error code otherwise.
*/
int32_t CN0411_ADC_ch1 (cn0411_device *cn0411_dev, uint8_t ch_en)
{
	int32_t ret;

	cn0411_dev->ad7124_dev.regs[AD7124_Channel_1].value =
		((ch_en << 15)
		 | AD7124_CH_MAP_REG_SETUP(1)
		 | AD7124_CH_MAP_REG_AINP(7)
		 | AD7124_CH_MAP_REG_AINM(17));
	ret = AD7124_WriteRegister(&cn0411_dev->ad7124_dev,
				   cn0411_dev->ad7124_dev.regs[AD7124_Channel_1]);

	return ret;
}

/**
 * AD7124 Channel 2 configuration function
 *
 * @param cn0411_dev - The device structure.
 * @param ch_en - enable/disable ADC channel
 * @return 0 in case of success, negative error code otherwise.
*/
int32_t CN0411_ADC_ch2 (cn0411_device *cn0411_dev, uint8_t ch_en)
{
	int32_t ret;

	cn0411_dev->ad7124_dev.regs[AD7124_Channel_2].value =
		((ch_en << 15)
		 | AD7124_CH_MAP_REG_SETUP(1)
		 | AD7124_CH_MAP_REG_AINP(8)
		 | AD7124_CH_MAP_REG_AINM(17));
	ret = AD7124_WriteRegister(&cn0411_dev->ad7124_dev,
				   cn0411_dev->ad7124_dev.regs[AD7124_Channel_2]);

	return ret;
}

/**
 * AD7124 IO Control 1 configuration function
 *
 * @param cn0411_dev - The device structure.
 * @param ch_gain - select gain channel to be used.
 * @return 0 in case of success, negative error code otherwise.
*/
int32_t CN0411_ADC_set_io1 (cn0411_device *cn0411_dev, uint8_t ch_gain)
{
	int32_t ret;

	cn0411_dev->ad7124_dev.regs[AD7124_IOCon1].value =
		((ch_gain << 20)
		 | (AD7124_8_IO_CTRL1_REG_GPIO_CTRL3
		    | AD7124_8_IO_CTRL1_REG_GPIO_CTRL2
		    | AD7124_8_IO_CTRL1_REG_GPIO_CTRL1)
		 | AD7124_IO_CTRL1_REG_IOUT0(3)
		 | AD7124_IO_CTRL1_REG_IOUT_CH0(0));
	ret = AD7124_WriteRegister(&cn0411_dev->ad7124_dev,
				   cn0411_dev->ad7124_dev.regs[AD7124_IOCon1]);

	return ret;
}

/**
 * AD7124 IO Control 2 configuration function
 *
 * @param cn0411_dev - The device structure.
 * @return 0 in case of success, negative error code otherwise.
**/
int32_t CN0411_ADC_set_io2 (cn0411_device *cn0411_dev)
{
	int32_t ret;

	/* All VBias off */
	cn0411_dev->ad7124_dev.regs[AD7124_IOCon2].value = 0x0000;
	ret = AD7124_WriteRegister(&cn0411_dev->ad7124_dev,
				   cn0411_dev->ad7124_dev.regs[AD7124_IOCon2]);

	return ret;
}

/**
 * CN0411 ADC conversion mode initialization
 *
 * @param cn0411_dev - The device structure.
 * @param conv_mod - set conversion mode
 * @return 0 in case of success, negative error code otherwise.
*/
int32_t CN0411_adc_conv_init(cn0411_device *cn0411_dev, uint8_t conv_mod)
{
	int32_t ret;

	switch(conv_mod) {
	case ADC_SINGLE_CONV:
		cn0411_dev->conv_type = ADC_SINGLE_CONV;
		ret = CN0411_ADC_ch0 (cn0411_dev, ADC_CH_DISABLE);
		ret |= CN0411_ADC_ch1 (cn0411_dev, ADC_CH_DISABLE);
		ret |= CN0411_ADC_ch2 (cn0411_dev, ADC_CH_DISABLE);
		ret |= CN0411_ADC_operation_mode(cn0411_dev, IDLE_MODE);
		break;
	case ADC_CONTINUOUS_CONV:
		cn0411_dev->conv_type = ADC_CONTINUOUS_CONV;
		ret = CN0411_ADC_ch0 (cn0411_dev, ADC_CH_ENABLE);
		ret |= CN0411_ADC_ch1 (cn0411_dev, ADC_CH_ENABLE);
		ret |= CN0411_ADC_ch2 (cn0411_dev, ADC_CH_ENABLE);
		ret |= CN0411_ADC_operation_mode(cn0411_dev, CONTINUOUS_CONV);
		break;
	default:
		ret = -1;
		break;
	}

	return ret;
}

/**
 * CN0411 read temperature
 *
 * Reads channel 0 of the ADC
 * Based on the conversion mode used:
 * 	- continuous: since the function is called by the user and the sequence
 * 	  of channels conversions cannot be controlled individually, the function
 * 	  assures that the conversion data is read properly, gathering the data only
 * 	  after the transition is made on the desired ADC channel. Therefore, if the
 * 	  currently converted ADC channel is channel 0, the	program waits until next
 * 	  channel conversion is made and reads the data register when transition to
 * 	  channel 0 is detected.
 * 	- single: read channel 0 individually
 *
 * @param cn0411_dev - The device structure.
 * @param temp - holds the temperature value
 * @return 0 in case of success, negative error code otherwise.
*/
int32_t CN0411_read_temp(cn0411_device *cn0411_dev, float *temp)
{
	int32_t ret;
	uint32_t ch0_data, status_reg;

	switch (cn0411_dev->conv_type) {
	case ADC_CONTINUOUS_CONV:
		ret = AD7124_ReadRegister(&cn0411_dev->ad7124_dev,
					  &cn0411_dev->ad7124_dev.regs[AD7124_Status]);
		status_reg = cn0411_dev->ad7124_dev.regs[AD7124_Status].value
			     & ADC_CH_RDY_MSK;

		while(status_reg == ADC_CH0) {
			ret |= AD7124_ReadRegister(&cn0411_dev->ad7124_dev,
						   &cn0411_dev->ad7124_dev.regs[AD7124_Status]);
			status_reg = cn0411_dev->ad7124_dev.regs[AD7124_Status].value
				     & ADC_CH_RDY_MSK;
		}
		while(status_reg != ADC_CH0) {
			ret |= AD7124_ReadRegister(&cn0411_dev->ad7124_dev,
						   &cn0411_dev->ad7124_dev.regs[AD7124_Status]);
			status_reg = cn0411_dev->ad7124_dev.regs[AD7124_Status].value
				     & ADC_CH_RDY_MSK;
		}
		ret |= AD7124_ReadRegister(&cn0411_dev->ad7124_dev,
					   &cn0411_dev->ad7124_dev.regs[AD7124_Data]);
		ch0_data = cn0411_dev->ad7124_dev.regs[AD7124_Data].value;
		break;
	case ADC_SINGLE_CONV:
		ret = CN0411_ADC_ch0 (cn0411_dev, ADC_CH_ENABLE);
		ret |= CN0411_ADC_operation_mode(cn0411_dev, SINGLE_CONV);
		if (AD7124_WaitForConvReady(&cn0411_dev->ad7124_dev, ADC_TIMEOUT)
		    == -3) {
			printf("TIMEOUT\n");
			return -1;
		}
		ret |= AD7124_ReadRegister(&cn0411_dev->ad7124_dev,
					   &cn0411_dev->ad7124_dev.regs[AD7124_Data]);
		ch0_data = cn0411_dev->ad7124_dev.regs[AD7124_Data].value;
		ret |= CN0411_ADC_ch0 (cn0411_dev, ADC_CH_DISABLE);
		break;
	default:
		ret = CN0411_FAILURE;
		break;
	}
	float resistance = (float)(ch0_data) * RTD_REF_RES / 0xFFFFFF;
	if(resistance < cn0411_dev->rtd_res)
		*temp = -242.02 + 2.228 * resistance + (2.5859 * pow(10, -3))
			* pow(resistance, 2) - (48260.0 * pow(10, -6))
			* pow(resistance, 3) - (2.8183 * pow(10, -3))
			* pow(resistance, 4) + (1.5243 * pow(10, -10))
			* pow(resistance, 5);
	else
		*temp = (-A + sqrt((pow(A, 2) - 4 * B * (1 - resistance
				    / cn0411_dev->rtd_res)))) / (2 * B);

	return ret;
}

/**
 * CN0411 read peak-to-peak voltage
 *
 * Reads channel 1 and 2 of the ADC
 * Based on the conversion mode used:
 * 	- continuous: since the function is called by the user and the sequence
 * 	  of channels conversions cannot be controlled individually, the function
 * 	  assures that the conversion data is read properly, gathering the data only
 * 	  after the transition is made on the desired ADC channel. Therefore, if the
 * 	  currently converted ADC channel is channel 1, the	program waits until next
 * 	  channel conversion is made and reads the data register when transition to
 * 	  channel 1 is detected. Then data register is read again when transition to
 * 	  channel 2 is detected.
 * 	- single: read channel 1 and 2 individually
 *
 * @param cn0411_dev - The device structure.
 * @param vpp - holds the peak-to-peak voltage value
 * @return peak-to-peak voltage value
*/
int32_t CN0411_read_vpp(cn0411_device *cn0411_dev, float *vpp)
{
	int32_t ret;
	uint32_t ch1_data, ch2_data, status_reg;
	float vch1, vch2;

	switch (cn0411_dev->conv_type) {
	case ADC_CONTINUOUS_CONV:
		ret = AD7124_ReadRegister(&cn0411_dev->ad7124_dev,
					  &cn0411_dev->ad7124_dev.regs[AD7124_Status]);
		status_reg = cn0411_dev->ad7124_dev.regs[AD7124_Status].value
			     & ADC_CH_RDY_MSK;
		while(status_reg == ADC_CH1) {
			ret |= AD7124_ReadRegister(&cn0411_dev->ad7124_dev,
						   &cn0411_dev->ad7124_dev.regs[AD7124_Status]);
			status_reg = cn0411_dev->ad7124_dev.regs[AD7124_Status].value
				     & ADC_CH_RDY_MSK;
		}
		while(status_reg != ADC_CH1) {
			ret |= AD7124_ReadRegister(&cn0411_dev->ad7124_dev,
						   &cn0411_dev->ad7124_dev.regs[AD7124_Status]);
			status_reg = cn0411_dev->ad7124_dev.regs[AD7124_Status].value
				     & ADC_CH_RDY_MSK;
		}
		ret |= AD7124_ReadRegister(&cn0411_dev->ad7124_dev,
					   &cn0411_dev->ad7124_dev.regs[AD7124_Data]);
		ch1_data = cn0411_dev->ad7124_dev.regs[AD7124_Data].value;
		while(status_reg != ADC_CH2) {
			ret |= AD7124_ReadRegister(&cn0411_dev->ad7124_dev,
						   &cn0411_dev->ad7124_dev.regs[AD7124_Status]);
			status_reg = cn0411_dev->ad7124_dev.regs[AD7124_Status].value
				     & ADC_CH_RDY_MSK;
		}
		ret |= AD7124_ReadRegister(&cn0411_dev->ad7124_dev,
					   &cn0411_dev->ad7124_dev.regs[AD7124_Data]);
		ch2_data = cn0411_dev->ad7124_dev.regs[AD7124_Data].value;
		break;
	case ADC_SINGLE_CONV:
		ret = CN0411_ADC_ch1 (cn0411_dev, ADC_CH_ENABLE);
		ret |= CN0411_ADC_operation_mode(cn0411_dev, SINGLE_CONV);
		if (AD7124_WaitForConvReady(&cn0411_dev->ad7124_dev, ADC_TIMEOUT)
		    == -3) {
			printf("TIMEOUT\n");
			return -1;
		}
		ret |= AD7124_ReadRegister(&cn0411_dev->ad7124_dev,
					   &cn0411_dev->ad7124_dev.regs[AD7124_Data]);
		ch1_data = cn0411_dev->ad7124_dev.regs[AD7124_Data].value;
		ret |= CN0411_ADC_ch1 (cn0411_dev, ADC_CH_DISABLE);

		ret |= CN0411_ADC_ch2 (cn0411_dev, ADC_CH_ENABLE);
		ret |= CN0411_ADC_operation_mode(cn0411_dev, SINGLE_CONV);
		if (AD7124_WaitForConvReady(&cn0411_dev->ad7124_dev, ADC_TIMEOUT)
		    == -3) {
			printf("TIMEOUT\n");
			return -1;
		}
		ret |= AD7124_ReadRegister(&cn0411_dev->ad7124_dev,
					   &cn0411_dev->ad7124_dev.regs[AD7124_Data]);
		ch2_data = cn0411_dev->ad7124_dev.regs[AD7124_Data].value;
		ret |= CN0411_ADC_ch2 (cn0411_dev, ADC_CH_DISABLE);
		break;
	default:
		ret = CN0411_FAILURE;
		break;
	}
	vch1 = ch1_data * VREF / 0xFFFFFF;
	vch2 = ch2_data * VREF / 0xFFFFFF;
	*vpp = vch1 + vch2;

	return ret;
}

/**
 * CN0411 compute electric conductivity
 *
 * @param cn0411_dev - The device structure.
 * @param cond - holds the conductivity value
 * @return 0 in case of success, negative error code otherwise.
*/
int32_t CN0411_compute_cond(cn0411_device *cn0411_dev, float *cond)
{
	int32_t ret;
	float vpp, ipp, res, g;

	ret = CN0411_premeasurement(cn0411_dev);
	ret |= CN0411_read_vpp(cn0411_dev, &vpp);
	ipp = (2*(cn0411_dev->v_exc) - vpp)
	      / cn0411_dev->r_gain[cn0411_dev->ch_gain];
	res = vpp/ipp - (cn0411_dev->offset_res);
	g = 1/res;
	*cond = cn0411_dev->cell_const * g;

	return ret;
}

/**
 * CN0411 compute offset resistance
 *
 * @param cn0411_dev - The device structure.
 * @return 0 in case of success, negative error code otherwise.
*/
int32_t CN0411_compute_off_res(cn0411_device *cn0411_dev)
{
	int32_t ret;
	float vpp, ipp;

	ret = CN0411_premeasurement(cn0411_dev);
	ret |= CN0411_read_vpp(cn0411_dev, &vpp);
	ipp = (2*(cn0411_dev->v_exc) - vpp)
	      / cn0411_dev->r_gain[cn0411_dev->ch_gain];
	cn0411_dev->offset_res = vpp/ipp - PREC_REF_RES;

	return ret;
}

/**
 * CN0411 temperature compensation of conductivity
 *
 * @param cn0411_dev - The device structure.
 * @param comp_cond - holds the compensated conductivity value
 * @return 0 in case of success, negative error code otherwise.
*/
int32_t CN0411_compensate_cond(cn0411_device *cn0411_dev, float *comp_cond)
{
	int32_t ret;
	float cond, temp;

	ret = CN0411_read_temp(cn0411_dev, &temp);
	ret |= CN0411_compute_cond(cn0411_dev, &cond);
	*comp_cond = cond / (1 + cn0411_dev->solution.temp_coeff * (temp - TCAL));

	return ret;
}

/**
 * CN0411 compute TDS
 *
 * @param cn0411_dev - The device structure.
 * @param tds - holds the tds value
 * @return 0 in case of success, negative error code otherwise.
*/
int32_t CN0411_compute_tds(cn0411_device *cn0411_dev, float *tds)
{

	int32_t ret;
	float comp_cond;

	ret = CN0411_compensate_cond(cn0411_dev, &comp_cond);
	*tds = cn0411_dev->solution.tds_factor * comp_cond;

	return ret;
}

/**
 * CN0411 ADC channels internal software calibration
 *
 * @param cn0411_dev - The device structure.
 * @return 0 in case of success, negative error code otherwise.
*/
int32_t CN0411_ADC_int_calibrate(cn0411_device *cn0411_dev)
{
	int32_t ret;

	ret = CN0411_ADC_ch0 (cn0411_dev, ADC_CH_ENABLE);
	ret |= CN0411_ADC_operation_mode(cn0411_dev, CAL_INT_ZERO_MODE);
	timer_sleep(1000u);
	ret |= CN0411_ADC_ch0 (cn0411_dev, ADC_CH_DISABLE);
	ret |= CN0411_ADC_ch1 (cn0411_dev, ADC_CH_ENABLE);;
	ret |= CN0411_ADC_operation_mode(cn0411_dev, CAL_INT_ZERO_MODE);
	timer_sleep(1000u);
	ret |= CN0411_ADC_ch1 (cn0411_dev, ADC_CH_DISABLE);
	ret |= CN0411_ADC_ch2 (cn0411_dev, ADC_CH_ENABLE);
	ret |= CN0411_ADC_operation_mode(cn0411_dev, CAL_INT_ZERO_MODE);
	timer_sleep(1000u);
	ret |= CN0411_ADC_ch2 (cn0411_dev, ADC_CH_DISABLE);

	return ret;
}

/**
 * CN0411 ADC channels system calibration
 *
 * @param cn0411_dev - The device structure.
 * @return 0 in case of success, negative error code otherwise.
*/
int32_t CN0411_ADC_sys_calibrate(cn0411_device *cn0411_dev)
{
	int32_t ret;

	ret = CN0411_ADC_operation_mode(cn0411_dev, IDLE_MODE);
	ret |= CN0411_ADC_ch0 (cn0411_dev, ADC_CH_DISABLE);
	ret |= CN0411_ADC_ch1 (cn0411_dev, ADC_CH_DISABLE);
	ret |= CN0411_ADC_ch2 (cn0411_dev, ADC_CH_DISABLE);
	pwm_status = PWM_SYSCALIB_AIN7;
	ret |= CN0411_ADC_ch1 (cn0411_dev, ADC_CH_ENABLE);;
	ret |= CN0411_ADC_operation_mode(cn0411_dev, CAL_SYS_ZERO_MODE);
	timer_sleep(1000u);
	ret |= CN0411_ADC_operation_mode(cn0411_dev, CAL_SYS_FULL_MODE);
	timer_sleep(1000u);
	ret |= CN0411_ADC_ch1 (cn0411_dev, ADC_CH_DISABLE);
	pwm_status = PWM_SYSCALIB_AIN8;
	ret |= CN0411_ADC_ch2 (cn0411_dev, ADC_CH_ENABLE);;
	ret |= CN0411_ADC_operation_mode(cn0411_dev, CAL_SYS_ZERO_MODE);
	timer_sleep(1000u);
	ret |= CN0411_ADC_operation_mode(cn0411_dev, CAL_SYS_FULL_MODE);
	timer_sleep(1000u);
	ret |= CN0411_ADC_ch2 (cn0411_dev, ADC_CH_DISABLE);
	pwm_status = PWM_CONVERSION;
	ret |= CN0411_ADC_ch0 (cn0411_dev, ADC_CH_ENABLE);
	ret |= CN0411_ADC_ch1 (cn0411_dev, ADC_CH_ENABLE);
	ret |= CN0411_ADC_ch2 (cn0411_dev, ADC_CH_ENABLE);

	return ret;
}

/**
 * CN0411 Premeasurement Process
 *
 * Set gain resistor based on the read DAC value
 *
 * @param cn0411_dev - The device structure.
 * @return 0 in case of success, negative error code otherwise.
*/
int32_t CN0411_premeasurement(cn0411_device *cn0411_dev)
{
	int32_t ret;
	float vpp;

	cn0411_dev->ch_gain = MUX_DEFAULT_CH;
	cn0411_dev->v_exc = cn0411_dev->v_dac;
	ret = CN0411_DAC_set_value(cn0411_dev, cn0411_dev->v_exc);
	while (cn0411_dev->ch_gain >= 0) {
		ret |= CN0411_ADC_set_io1 (cn0411_dev, cn0411_dev->ch_gain);
		ret |= CN0411_read_vpp(cn0411_dev, &vpp);
		if((vpp > 0.3 * 2 * cn0411_dev->v_exc)
		    || (cn0411_dev->ch_gain == 0)) {
			cn0411_dev->v_dac = 0.2 * cn0411_dev->v_exc / vpp;
			ret |= CN0411_DAC_set_value(cn0411_dev, cn0411_dev->v_exc);
			break;
		} else {
			cn0411_dev->ch_gain--;
		}
	}

	return ret;
}
/**
 * Find available commands
 *
 * @param cmd - command to search
 * @return cmd_func - return the specific function for available command or
 * NULL for invalid command
*/
cmd_func CN0411_find_command(char *cmd)
{
	cmd_func func = NULL;
	int i = 0;

	while (cmd_fun[i] != NULL) {
		if (strncmp(cmd, cmd_commands[i], 6) == 0) {
			func = cmd_fun[i];
			break;
		}

		i++;
	}

	return func;
}

/**
 * Command line process function
 *
 * @param cn0411_dev - The device structure.
 * @return none
*/
void CN0411_cmd_process(cn0411_device *cn0411_dev)
{
	cmd_func func;

	/* Check if <ENTER> key was pressed */
	if (uart_cmd == UART_TRUE) {

		/* Find needed function based on typed command */
		func = CN0411_find_command((char *)uart_rx_buffer);

		/* Check if there is a valid command */
		if (func) {
			printf("\n");
			/* Call the desired function */
			(*func)(&uart_rx_buffer[2], cn0411_dev);

			/* Check if there is no match for typed command */
		} else if (strlen((char *)uart_rx_buffer) != 0) {
			printf("\n");
			/* Display a message for unknown command */
			printf("Unknown command!");
			printf("\n");
		}

		/* Prepare for next <ENTER> */
		uart_cmd = UART_FALSE;
		CN0411_cmd_prompt();
	}
}

/**
 * Command line prompt
 *
 * @return 0 in case of success, negative error code otherwise.
*/
int32_t CN0411_cmd_prompt(void)
{
	int32_t res;
	static uint8_t count = 0;

	res = UART_WriteChar(_CR, UART_WRITE_NO_INT);
	if (res == UART_SUCCESS) {
		res = UART_WriteChar(_LF, UART_WRITE_NO_INT);
	}
	/* Check first <ENTER> is pressed after reset */
	if(count == 0) {
		printf("\tWelcome to CN0411 application!\n");
		printf("Type <help> to see available commands...\n");
		printf("\n");
		count++;
	}
	if (res == UART_SUCCESS) {
		UART_WriteChar(':', UART_WRITE_NO_INT);
	}
	uart_rcnt = 0;

	return res;
}

/**
 * Finds the next command line argument
 *
 * @param args - pointer to the arguments on the command line.
 * @return pointer to the next argument.
*/
uint8_t *CN0411_find_argv(uint8_t *args)
{
	uint8_t *p = args;
	int fl = 0;

	while (*p != 0) {
		if ((*p == _SPC)) {
			fl = 1;
		} else {
			if (fl) {
				break;
			}
		}
		p++;
	}

	return p;
}

/**
 * Separates a command line argument
 *
 * @param dst - pointer to a buffer where the argument will be copied
 * @param args - pointer to the current position of the command line .
 * @return none
*/
void CN0411_get_argv(char *dst, uint8_t *args)
{
	uint8_t *s = args;
	char *d = dst;

	while (*s) {
		if (*s == _SPC) {
			break;
		}
		*d++ = *s++;
	}
	*d = '\0';
}


/**
 * Display info for <help> command
 *
 * @param args - pointer to the arguments on the command line.
 * @param cn0411_dev - The device structure.
 * @return none
*/
void CN0411_cmd_help(uint8_t *args, cn0411_device *cn0411_dev)
{
	printf("\n");
	printf("Available commands:\n");
	printf(" help                          - Display available commands\n");
	printf(" convmod (sing/cont)           - set single/continuous conversion "
	       "mode for ADC \n");
	printf(" syscal                        - Perform ADC system "
	       "calibration \n");
	printf("                                 Before calibration, short "
	       "terminals 5 & 6 \n");
	printf(" refres                        - Perform Referencing to a "
	       "Precision Resistance \n");
	printf("                                 calibration \n");
	printf("                                 Before referencing, short "
	       "terminals 3 & 4 \n");
	printf("                                 in jumper P1. \n");
	printf(" dacval <val>                  - Set DAC value (Volts) \n");
	printf("                                 <val> = values from 0 to 2.5 \n");
	printf(" rtdval <val>                  - Set RTD value (Ω) \n");
	printf("                                 <val> = values 100, 1000 \n");
	printf(" pwmfreq <val>                 - Set PWM frequency value (Hz) \n");
	printf("                                 <val> = values 300, 2400 \n");
	printf(" cellconst (low/normal/high)   - set cell constant for "
	       "conductivity types\n");
	printf(" solution (kcl/nacl)           - set parameters for specific "
	       "solution \n");
	printf(" temp                          - Display temperature value\n");
	printf(" cond                          - Display conductivity value\n");
	printf(" tds                           - Display TDS value\n");
}

/**
 * Set System Calibration via UART
 *
 * @param args - pointer to the arguments on the command line.
 * @param cn0411_dev - The device structure.
 * @return none
*/
void CN0411_cmd_sys_calib(uint8_t *args, cn0411_device *cn0411_dev)
{
	int32_t ret;

	printf("ADC System Calibration in progress...\n");
	ret = CN0411_ADC_sys_calibrate(cn0411_dev);
	if(ret == CN0411_SUCCESS)
		printf("ADC System Calibration completed!\n");
	else
		printf("ADC System Calibration failed!\n");
}

/**
 * Referencing to a Precision Resistance via UART
 *
 * @param args - pointer to the arguments on the command line.
 * @param cn0411_dev - The device structure.
 * @return none
*/
void CN0411_cmd_off_res(uint8_t *args, cn0411_device *cn0411_dev)
{
	int32_t ret;

	printf("Referencing to a Precision Resistance in progress...\n");
	ret = CN0411_compute_off_res(cn0411_dev);
	if(ret == CN0411_SUCCESS)
		printf("Referencing to a Precision Resistance completed!\n");
	else
		printf("Referencing to a Precision Resistance failed!\n");
}

/**
 * Set Conversion Mode via UART
 *
 * @param args - pointer to the arguments on the command line.
 * @param cn0411_dev - The device structure.
 * @return none
*/
void CN0411_cmd_conv_mode(uint8_t *args, cn0411_device *cn0411_dev)
{
	int32_t ret;
	uint8_t *p = args;
	char arg[5];

	/* Check if this function gets an argument */
	while (*(p = CN0411_find_argv(p)) != '\0') {
		/* Save conversion mode parameter */
		CN0411_get_argv(arg, p);
	}
	if(!strcmp(arg, "sing")) {
		ret = CN0411_adc_conv_init(cn0411_dev, ADC_SINGLE_CONV);
		printf("ADC set to single Conversion Mode.\n");
	} else if (!strcmp(arg, "cont")) {
		ret = CN0411_adc_conv_init(cn0411_dev, ADC_CONTINUOUS_CONV);
		printf("ADC set to continuous Conversion Mode.\n");
	} else {
		printf("Incorrect input value!\n");
	}
	if (ret != CN0411_SUCCESS) {
		printf("Conversion Mode initialization failed!\n");
	}
}

/**
 * Set DAC value via UART
 *
 * @param args - pointer to the arguments on the command line.
 * @param cn0411_dev - The device structure.
 * @return none
*/
void CN0411_cmd_dac_val(uint8_t *args, cn0411_device *cn0411_dev)
{
	int32_t ret;
	uint8_t *p = args;
	float input_val;
	char arg[5];

	/* Check if this function gets an argument */
	while (*(p = CN0411_find_argv(p)) != '\0') {
		/* Save DAC value */
		CN0411_get_argv(arg, p);
	}
	input_val = atof(arg);
	if(input_val < 0 || input_val > 2.5) {
		printf("Input out of range!.\n");
	} else {
		cn0411_dev->v_dac = input_val;
		ret = CN0411_premeasurement(cn0411_dev);
		printf("DAC value set to %s V.\n", arg);
	}
	if (ret != CN0411_SUCCESS) {
		printf("Set DAC value failed!.\n");
	}
}

/**
 * Set RTD resistance value via UART
 *
 * @param args - pointer to the arguments on the command line.
 * @param cn0411_dev - The device structure.
 * @return none
*/

void CN0411_cmd_rtd_val(uint8_t *args, cn0411_device *cn0411_dev)
{
	uint8_t *p = args;
	float input_val;
	char arg[6];

	/* Check if this function gets an argument */
	while (*(p = CN0411_find_argv(p)) != '\0') {
		/* Save RTD value parameter */
		CN0411_get_argv(arg, p);
	}
	input_val = atof(arg);
	if(input_val == 100) {
		cn0411_dev->rtd_res = RTD_RES_100;
		printf("RTD value set to 100Ω.\n");
	} else if(input_val == 1000) {
		cn0411_dev->rtd_res = RTD_RES_1K;
		printf("RTD value set to 1kΩ.\n");
	} else {
		printf("Incorrect value!\n");
	}
}

/**
 * Set PWM frequency via UART
 *
 * @param args - pointer to the arguments on the command line.
 * @param cn0411_dev - The device structure.
 * @return none
*/

void CN0411_cmd_pwm_freq(uint8_t *args, cn0411_device * cn0411_dev)
{
	uint8_t *p = args;
	float input_val;
	char arg[6];

	/* Check if this function gets an argument */
	while (*(p = CN0411_find_argv(p)) != '\0') {
		/* Save PWM frequency parameter */
		CN0411_get_argv(arg, p);
	}
	input_val = atoi(arg);
	if(input_val == PWM_FREQ_300 || input_val == PWM_FREQ_2400) {
		CN0411_pwm_freq(input_val);
		if(input_val == PWM_FREQ_300)
			printf("PWM frequency set to 300Hz.\n");
		else
			printf("PWM frequency set to 2.4kHz.\n");
	} else {
		printf("Incorrect value!\n");
	}
}

/**
 * Set Cell Constant type via UART
 *
 * @param args - pointer to the arguments on the command line.
 * @param cn0411_dev - The device structure.
 * @return none
*/

void CN0411_cmd_cell_const(uint8_t *args, cn0411_device *cn0411_dev)
{
	uint8_t *p = args;
	char arg[7];

	/* Check if this function gets an argument */
	while (*(p = CN0411_find_argv(p)) != '\0') {
		/* Save cell constant parameter */
		CN0411_get_argv(arg, p);
	}
	if(!strcmp(arg, "low")) {
		cn0411_dev->cell_const = CELL_CONST_LOW;
		printf("Cell Constant set to low.\n");
	} else if (!strcmp(arg, "normal")) {
		cn0411_dev->cell_const = CELL_CONST_NORMAL;
		printf("Cell Constant set to normal.\n");
	} else if (!strcmp(arg, "high")) {
		cn0411_dev->cell_const = CELL_CONST_HIGH;
		printf("Cell Constant set to high.\n");
	} else {
		printf("Incorrect input value!\n");
	}
}

/**
 * Set Solution parameters via UART
 *
 * @param args - pointer to the arguments on the command line.
 * @param cn0411_dev - The device structure.
 * @return none
*/
void CN0411_cmd_solution(uint8_t *args, cn0411_device *cn0411_dev)
{
	uint8_t *p = args;
	char arg[5];

	/* Check if this function gets an argument */
	while (*(p = CN0411_find_argv(p)) != '\0') {
		/* Save solution parameter */
		CN0411_get_argv(arg, p);
	}
	if(!strcmp(arg, "kcl")) {
		cn0411_dev->solution.temp_coeff = TEMP_COEFF_KCL;
		cn0411_dev->solution.tds_factor = TDS_KCL;
		printf("Solution set to KCl.\n");
	} else if (!strcmp(arg, "nacl")) {
		cn0411_dev->solution.temp_coeff = TEMP_COEFF_NACL;
		cn0411_dev->solution.tds_factor = TDS_NACL;
		printf("Solution set to NaCl.\n");
	} else {
		printf("Incorrect input value!\n");
	}
}

/**
 * Print Temperature value via UART
 *
 * @param args - pointer to the arguments on the command line.
 * @param cn0411_dev - The device structure.
 * @return none
*/
void CN0411_cmd_temp(uint8_t *args, cn0411_device *cn0411_dev)
{
	int32_t ret;
	float temp;

	ret = CN0411_read_temp(cn0411_dev, &temp);
	if(ret == CN0411_SUCCESS) {
		printf("Temperature = %.2f[˚C]\n", temp);
	} else {
		printf("Get Temperature value failed!\n");
	}
}

/**
 * Print Conductivity value via UART
 *
 * @param args - pointer to the arguments on the command line.
 * @param cn0411_dev - The device structure.
 * @return none
*/
void CN0411_cmd_cond(uint8_t *args, cn0411_device *cn0411_dev)
{
	int32_t ret;
	float cond;

	ret = CN0411_compensate_cond(cn0411_dev, &cond);
	if(ret == CN0411_SUCCESS) {
		printf("Conductivity = %.10f\n", cond);
	} else {
		printf("Get Conductivity value failed!\n");
	}
}

/**
 * Print TDS value via UART
 *
 * @param args - pointer to the arguments on the command line.
 * @param cn0411_dev - The device structure.
 * @return none
*/
void CN0411_cmd_tds(uint8_t *args, cn0411_device *cn0411_dev)
{
	int32_t ret;
	float tds;

	ret = CN0411_compute_tds(cn0411_dev, &tds);
	if(ret == CN0411_SUCCESS) {
		printf("TDS = %.10f\n", tds);
	} else {
		printf("Get TDS value failed!\n");
	}
}

/**
 * Internal interrupt handler for UART

 * @return none
*/
void CN0411_interrupt(void)
{
	unsigned short status;
	char c;

	status = UrtIntSta(pADI_UART);
	if (status & COMIIR_NINT) {
		return;   /* Check if UART is busy */
	}
	switch (status & COMIIR_STA_MSK) {
	case COMIIR_STA_RXBUFFULL:
		UART_ReadChar(&c);
		switch(c) {
		case _BS:
			if (uart_rcnt) {
				uart_rcnt--;
				uart_rx_buffer[uart_rcnt] = 0;
				UART_WriteChar(c, UART_WRITE_IN_INT);
				UART_WriteChar(' ', UART_WRITE_IN_INT);
				UART_WriteChar(c, UART_WRITE_IN_INT);
			}
			break;
		case _CR: /* Check if read character is ENTER */
			uart_cmd = UART_TRUE;                    /* Set flag */
			break;
		default:
			uart_rx_buffer[uart_rcnt++] = c;

			if (uart_rcnt == UART_RX_BUFFER_SIZE) {
				uart_rcnt--;
				UART_WriteChar(_BS, UART_WRITE_IN_INT);
			}
			UART_WriteChar(c, UART_WRITE_IN_INT);
		}
		uart_rx_buffer[uart_rcnt] = '\0';
		break;
	case COMIIR_STA_TXBUFEMPTY:
		if (uart_tcnt) {
			uart_tbusy = UART_TRUE;
			uart_tcnt--;
			UART_WriteChar(uart_tx_buffer[uart_tpos++], UART_WRITE);
			if (uart_tpos == UART_TX_BUFFER_SIZE) {
				uart_tpos = 0;
			}
		} else {
			uart_tbusy = UART_FALSE;
		}
		break;
	default:
		;
	}
}

/**
 * Set PWM frequency
 *
 * @param freq - frequency value to be set.
 * @return none
*/
void CN0411_pwm_freq(uint16_t freq)
{
	switch (freq) {
	case PWM_FREQ_300:
		pwm_step = 50;
		pwm2_high = 1 * pwm_step;
		pwm2_low = 2 * pwm_step;
		pwm0_high = 3 * pwm_step;
		pwm1_high = 4 * pwm_step;
		pwm1_low = 5 * pwm_step;
		pwm0_low = 6 * pwm_step;
		pwm_tick_count = 0;
		break;
	case PWM_FREQ_2400:
		pwm_step = 6;
		pwm2_high = 1 * pwm_step;
		pwm2_low = 2 * pwm_step;
		pwm0_high = 3 * pwm_step;
		pwm1_high = 4 * pwm_step;
		pwm1_low = 5 * pwm_step;
		pwm0_low = 6 * pwm_step;
		pwm_tick_count = 0;
		break;
	default:
		break;
	}
}

/**
 * Generate PWM

 * @return none
*/
void CN0411_pwm_gen(void)
{
	switch(pwm_status) {
	case PWM_SYSCALIB_AIN7:
		DioClr(pADI_GP1, BIT4);
		DioSet(pADI_GP1, BIT2|BIT3);
		break;
	case PWM_SYSCALIB_AIN8:
		DioClr(pADI_GP1, BIT2|BIT3);
		DioSet(pADI_GP1, BIT4);
		break;
	case PWM_CONVERSION:
		if(pwm_tick_count==0) {
			DioClr(pADI_GP1, BIT2|BIT3|BIT4);
		} else if (pwm_tick_count == pwm2_high) {
			DioSet(pADI_GP1, BIT4);
		} else if (pwm_tick_count == pwm2_low) {
			DioClr(pADI_GP1, BIT4);
		} else if (pwm_tick_count == pwm0_high) {
			DioSet(pADI_GP1, BIT2);
		} else if (pwm_tick_count == pwm1_high) {
			DioSet(pADI_GP1, BIT3);
		} else if (pwm_tick_count == pwm1_low) {
			DioClr(pADI_GP1, BIT3);
		} else if (pwm_tick_count == pwm0_low) {
			pwm_tick_count = -1;
		}
		pwm_tick_count++;
		break;
	default:
		break;
	}
}

/**
 * CN0411 Initialization
 *
 * @param cn0411_dev - The device structure.
 * @return 0 in case of success, negative error code otherwise.
*/
int32_t CN0411_init(cn0411_device *cn0411_dev)
{
	int32_t ret;

	cn0411_dev->v_dac = DAC_OUT_DEFAULT_VAL;
	cn0411_dev->v_exc = EXC_DEFAULT_VAL;
	cn0411_dev->ch_gain = MUX_DEFAULT_CH;
	cn0411_dev->conv_type = ADC_SINGLE_CONV;
	cn0411_dev->r_gain[0] = 20;
	cn0411_dev->r_gain[1] = 200;
	cn0411_dev->r_gain[2] = 2000;
	cn0411_dev->r_gain[3] = 20000;
	cn0411_dev->r_gain[4] = 200000;
	cn0411_dev->r_gain[5] = 2000000;
	cn0411_dev->r_gain[6] = 20000000;
	cn0411_dev->offset_res = OFFSET_RES_INIT;
	cn0411_dev->rtd_res = RTD_RES_1K;
	cn0411_dev->cell_const = CELL_CONST_NORMAL;
	cn0411_dev->solution.temp_coeff = TEMP_COEFF_NACL;
	cn0411_dev->solution.tds_factor = TDS_NACL;

	CN0411_pwm_freq(2400);
	UART_Init();
	ret = SPI_Init();
	pwm_status = PWM_CONVERSION;

	/* Initial Setup ADC */
	ret |= AD7124_Setup(&cn0411_dev->ad7124_dev, CS_AD7124, ad7124_regs);

	/* Initial Setup DAC */
	ret |= AD5683_setup(&cn0411_dev->ad5683_dev, CS_AD5683);

	/* Setup ADC */
	ret |= CN0411_ADC_setup0 (cn0411_dev);
	ret |= CN0411_ADC_setup1 (cn0411_dev);
	ret |= CN0411_ADC_set_io1 (cn0411_dev, cn0411_dev->ch_gain);
	ret |= CN0411_ADC_set_io2 (cn0411_dev);
	ret |= CN0411_ADC_int_calibrate(cn0411_dev);

	ret |= CN0411_adc_conv_init(cn0411_dev, ADC_CONTINUOUS_CONV);

	if(ret == CN0411_SUCCESS) {
		printf("CN0411 Successfully Initialized!\n");
		printf("CN0411 Initial Setup:\n");
		printf("	- ADC set to Continuous Conversion Mode\n");
		printf("	- DAC output voltage set to 200mV\n");
		printf("	- PWM frequency set to 2.4kHz\n");
		printf("	- RTD resistance set to 1kΩ\n");
		printf("	- Cell Constant set to normal\n");
		printf("	- Solution set to NaCl\n");
	} else {
		printf("CN0411 Initialization error!\n");
	}
	return ret;
}
