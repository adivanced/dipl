#include <stdio.h>
#include <stdint.h>
#include <stddef.h>

#define BUTTON_TEST 						1 << 0
#define BUTTON_AIR_TEMPERATURE 				1 << 1
#define BUTTON_AIR_HUMIDITY 				1 << 2
#define BUTTON_CALIBRATION 					1 << 3
#define BUTTON_HORIZONTAL_WIND_SPEED 		1 << 4
#define BUTTON_ATMOSPHERIC_PRESSURE 		1 << 5
#define BUTTON_BRIGHTNESS 					1 << 6
#define BUTTON_HORIZONTAL_WIND_DIRECTION 	1 << 7
#define BUTTON_OBJECT_TEMPERATURE 			1 << 8
#define BUTTON_MEASURE 						1 << 9
#define BUTTON_VERTICAL_WIND_SPEED 			1 << 10
#define BUTTON_VERTICAL_STABILITY 			1 << 11

uint16_t arr[12] = {BUTTON_TEST, BUTTON_AIR_TEMPERATURE, BUTTON_AIR_HUMIDITY, BUTTON_CALIBRATION, BUTTON_HORIZONTAL_WIND_SPEED, BUTTON_ATMOSPHERIC_PRESSURE, BUTTON_BRIGHTNESS, BUTTON_HORIZONTAL_WIND_DIRECTION, BUTTON_OBJECT_TEMPERATURE, BUTTON_MEASURE, BUTTON_VERTICAL_WIND_SPEED, BUTTON_VERTICAL_STABILITY};

int main(){
	wchar_t c = 'Ю';
	printf("%d\n", c);
	c = 'Я';
	printf("%d\n", c);


}
