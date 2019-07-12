final int window_width = 1600;
final int window_height = 960;

final int mole_x = 5;
final int mole_y = 5;

int[] mole_up;
int[] is;

int[] hole_length;
int[] hole_x;
int[] hole_y;

int mole_num = 20;

int hammer_x = window_width / 2;
int hammer_y = window_height / 2;


int iro = 0;

int score = 0;


void bubble_sort() {
	int i, j;
	for (i = 0; i < mole_num - 1; i++)
		for (j = mole_num - 1; j >= i + 1; j--)
			if (hole_y[j] < hole_y[j - 1]) {
				int temp;
				temp = hole_y[j];
				hole_y[j] = hole_y[j - 1];
				hole_y[j - 1] = temp;
				temp = hole_x[j];
				hole_x[j] = hole_x[j - 1];
				hole_x[j - 1] = temp;
			}
}


void settings() {
	size(window_width, window_height);
}


import processing.serial.*;
Serial port;

void setup() {
	colorMode(RGB, 256);

	mole_up = new int[mole_x * mole_y];
	is = new int[mole_x * mole_y];

	hole_length = new int[mole_x * mole_y];
	hole_x = new int[mole_x * mole_y];
	hole_y = new int[mole_x * mole_y];
	for (int i = 0; i < 20; ++i) {
		hole_x[i] = 200 + int(random(window_width - 200)) / 200 * 200;
		hole_y[i] = 200 + int(random(window_height - 200)) / 100 * 100;

		for (int j = 0; j < i; ++j)
			if (hole_x[i] == hole_x[j] && hole_y[i] == hole_y[j]) {
				hole_x[j] = -10000 + int(random(window_width - 200));
				hole_y[j] = -10000 + int(random(window_width - 200));
			}

		mole_up[i] = 0;
		is[i] = 2;
		hole_length[i] = 200;
	}
	bubble_sort();

	port = new Serial(this, "COM3", 9600);
	port.clear();
}

void moleDraw(final int mu) {

	stroke(108, 173, 119);
	strokeWeight(0);
	fill(iro, iro, iro);
	ellipse(hole_x[mu], hole_y[mu], hole_length[mu], hole_length[mu] / 2);

	stroke(0);
	strokeWeight(hole_length[mu] / 20);
	fill(115, 66, 41);
	rect(hole_x[mu] - hole_length[mu] / 4, hole_y[mu] + hole_length[mu] / 9 - mole_up[mu], hole_length[mu] / 2, mole_up[mu]);

}

void draw() {
	background(108, 173, 119);

	int v, b0, b1, b2, b3, b4, b5;
	float g0 = 0, g1 = 0, g2 = 0;
	int poa = port.available();

	if (iro != 0) --iro;

	if (hammer_x < 0) hammer_x = 0;
	if (hammer_y < 0) hammer_y = 0;
	if (hammer_x > window_width) hammer_x = window_width;
	if (hammer_y > window_height) hammer_y = window_height;


	for (int i = 0; i < 20; ++i)
		moleDraw(i);

	strokeWeight(0);
	fill(127, 127, 127);
	ellipse(hammer_x, hammer_y, window_width / 16, window_width / 16);

	if (mousePressed == true)
		for (int i = 0; i < 20; ++i)
			mole_up[i] = 0;

	for (int i = 0; i < 20; ++i) {
		if (is[i] == 1) {
			if (mole_up[i] < hole_length[i] * 31 / 36) mole_up[i] += 3;
			else is[i] = 0;
		}
		else if (is[i] == 0) {
			if (mole_up[i] > 0) mole_up[i] -= 3;
			else is[i] = 2;
		}
		else {
			mole_up[i] = 0;
			if (int(random(200)) == 1) is[i] = 1;
		}
	}

	if (poa > 6) {

		while (poa > 7) port.read();

		b0 = port.read();
		b1 = port.read();
		b2 = port.read();
		b3 = port.read();
		b4 = port.read();
		b5 = port.read();

		g0 = -(float(int(b0 * 256 + b1) / 16)) / 1024;
		g1 = -(float(int(b2 * 256 + b3) / 16)) / 1024;
		g2 = -(float(int(b4 * 256 + b5) / 16)) / 1024;

		hammer_x += int((g0 + 1.9) * 30);
		hammer_y += int((g1 + 1.9) * 5);

		v = port.read();

		if (v == 1)
			for (int i = 0; i < 20; ++i) {
				if (is[i] == 2) continue;
				if (hole_x[i] - hole_length[i] / 2 <= hammer_x && hole_y[i] - hole_length[i] <= hammer_y && hole_x[i] + hole_length[i] * 3 / 2 >= hammer_x && hole_y[i] + hole_length[i] / 2 >= hammer_y) {
					mole_up[i] = 0;
					is[i] = 2;

					score += 10;

					strokeWeight(0);
					fill(255, 127, 127);
					ellipse(hammer_x, hammer_y, window_width / 8, window_width / 8);
				}
			}
	}

	stroke(55, 55, 55);
	strokeWeight(10);

	PFont font = createFont("MS Gothic", 48, true);
	textFont(font);

	fill(255, 255, 255);
	textSize(25);
	textSize(50);
	text("Score:" + str(score), 50, 50);

}