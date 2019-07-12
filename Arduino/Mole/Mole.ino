#include <Wire.h>

const int ADDRESS = 0x1D;
const int OUT_X_MSB = 0x01;
const int XYZ_DATA_CFG = 0x0E;
const int CTRL_REG1 = 0x2A;
const int CTRL_REG1_ACTV_BIT = 0x01;

void readByteArray(byte adrs, int datlen, byte* dest) {
	Wire.beginTransmission(ADDRESS);
	Wire.write(adrs);
	Wire.endTransmission(false);
	Wire.requestFrom(ADDRESS, datlen);

	while (Wire.available() < datlen);
	for (int x = 0; x < datlen; ++x)
		dest[x] = Wire.read();
}

byte readByte(byte adrs) {
	Wire.beginTransmission(ADDRESS);
	Wire.write(adrs);
	Wire.endTransmission(false);
	Wire.requestFrom(ADDRESS, 1);

	while (!Wire.available());
	return(Wire.read());
}

void writeByte(byte adrs, byte dat) {
	Wire.beginTransmission(ADDRESS);
	Wire.write(adrs);
	Wire.write(dat);
	Wire.endTransmission();
}

byte buf[6];
float acceleration[3] = {};
float old_acceleration[3] = {};
float old_old_acceleration[3] = {};
float attack = 0;
int is_attack = 0;
const int speaker = 9;

void setup() {

	pinMode(speaker, OUTPUT);

	byte tmp;

	Serial.begin(9600);
	Wire.begin();

	tmp = readByte(CTRL_REG1);
	writeByte(CTRL_REG1, tmp & ~(CTRL_REG1_ACTV_BIT));
	writeByte(XYZ_DATA_CFG, 0);
	tmp = readByte(CTRL_REG1);
	writeByte(CTRL_REG1, tmp | CTRL_REG1_ACTV_BIT);

	readByteArray(OUT_X_MSB, 6, buf);
	old_acceleration[0] = -(float(int(buf[0] * 256 + buf[1]) / 16)) / 1024;
	old_acceleration[1] = -(float(int(buf[2] * 256 + buf[3]) / 16)) / 1024;
	old_acceleration[2] = -(float(int(buf[4] * 256 + buf[5]) / 16)) / 1024;

	old_old_acceleration[0] = old_acceleration[0];
	old_old_acceleration[1] = old_acceleration[1];
	old_old_acceleration[2] = old_acceleration[2];
}

void loop() {

	readByteArray(OUT_X_MSB, 6, buf);
	acceleration[0] = -(float(int(buf[0] * 256 + buf[1]) / 16)) / 1024;
	acceleration[1] = -(float(int(buf[2] * 256 + buf[3]) / 16)) / 1024;
	acceleration[2] = -(float(int(buf[4] * 256 + buf[5]) / 16)) / 1024;

	if (abs(old_acceleration[2] - acceleration[2]) >= 2.0 && abs(old_acceleration[2] - old_old_acceleration[2]) >= 2.0) attack = 10;
	else attack = 0;

	Serial.write(buf[0]);
	Serial.write(buf[1]);
	Serial.write(buf[2]);
	Serial.write(buf[3]);
	Serial.write(buf[4]);
	Serial.write(buf[5]);

	is_attack = int(attack / 10);
	Serial.write(is_attack);

	old_old_acceleration[0] = old_acceleration[0];
	old_old_acceleration[1] = old_acceleration[1];
	old_old_acceleration[2] = old_acceleration[2];

	old_acceleration[0] = acceleration[0];
	old_acceleration[1] = acceleration[1];
	old_acceleration[2] = acceleration[2];

	if (is_attack == 1) tone(speaker, 262, 500);

	delay(100);
}
