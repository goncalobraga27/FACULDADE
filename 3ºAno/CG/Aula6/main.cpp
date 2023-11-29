

#include<stdio.h>
#include<stdlib.h>

#define _USE_MATH_DEFINES
#include <math.h>
#include <vector>

#include <IL/il.h>

#ifdef __APPLE__
#include <GLUT/glut.h>
#else
#include <GL/glew.h>
#include <GL/glut.h>
#endif


float camX = 00, camY = 30, camZ = 40;
int startX, startY, tracking = 0;

int alpha = 0, beta = 45, r = 50;
// Array of vertex to VBO's
float *vertexB; 
GLuint buffers[1];
int sizeArray=0;
unsigned char *imageData;

unsigned int t, tw, th;

void changeSize(int w, int h) {

	// Prevent a divide by zero, when window is too short
	// (you cant make a window with zero width).
	if(h == 0)
		h = 1;

	// compute window's aspect ratio 
	float ratio = w * 1.0 / h;

	// Reset the coordinate system before modifying
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	
	// Set the viewport to be the entire window
    glViewport(0, 0, w, h);

	// Set the correct perspective
	gluPerspective(45,ratio,1,1000);

	// return to the model view matrix mode
	glMatrixMode(GL_MODELVIEW);
}

void drawTerrain(){
	glPushMatrix();
	glTranslatef(-(float)tw / 2, 0,-(float)th / 2);
	glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
	glBindBuffer(GL_ARRAY_BUFFER,buffers[0]);
	glVertexPointer(3,GL_FLOAT,0,0);
	for(int i = 0; i < tw - 1; i++){
		glDrawArrays(GL_TRIANGLE_STRIP, i * 2 * tw, 2 * tw);
	}
	glPopMatrix();
}


float hf (float x, float z) {
	float resultado = 0.0;
	float fx = x - floor(x);
	float fz = z - floor(z);
	// altura*th+largura 
	// (altura+1)*th+largura
	float hx1 = (1-fz)*imageData[int(floor(x)*th+floor(z))]+fz*imageData[int((floor(x)+1)*th+floor(z))];
	float hx2 = (1-fz)*imageData[int(ceil(x)*th+ceil(z))]+fz*imageData[int((ceil(x)+1)*th+ceil(z))];
	resultado = (1-fx)*hx1+fx*hx2;
	return resultado;
}
void drawTrees(){
	
	int arvoresNaCena=0;
	srand(3);
	while(arvoresNaCena != 100){
		printf("ÁRVORE Nº:%d\n",arvoresNaCena);
		float xDesNormalized=(double)rand()/(double)RAND_MAX;
		printf("xDesNormalized:%f\n",xDesNormalized);
		float zDesNormalized=(double)rand()/(double)RAND_MAX;
		printf("yDesNormalized:%f\n",zDesNormalized);
		float x = xDesNormalized*(double)th-(double)th/2;
		float z = zDesNormalized*(double)tw-(double)tw/2;
		float y = hf(x,z);
		printf("X->%f\n",x);
		printf("Y->%f\n",y);
		printf("Z->%f\n",z);
		glPushMatrix();
		glTranslatef(x,y,z);
		glPushMatrix();
		glRotatef(-90.0f,1.0f,0.0f,0.0f); 
		glColor3f(1.4f,0.7f,0.2f);
		glutSolidCone(2,10,5,5);
		glPushMatrix();
		glColor3f(0.0f,0.3f,0.0f);
		glTranslatef(0.0f,0.0f,5.0f);
		glutSolidCone(2,10,5,5);
		glPopMatrix();
		glPopMatrix();
		glPopMatrix();
		arvoresNaCena++;
	}
	
}

void renderScene(void) {

	float pos[4] = {-1.0, 1.0, 1.0, 0.0};

	glClearColor(0.0f,0.0f,0.0f,0.0f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	glLoadIdentity();
	gluLookAt(camX, camY, camZ, 
		      0.0,0.0,0.0,
			  0.0f,1.0f,0.0f);
	drawTerrain();

	drawTrees();


// End of frame
	glutSwapBuffers();
}

void processKeys(unsigned char key, int xx, int yy) {

// put code to process regular keys in here
}



void processMouseButtons(int button, int state, int xx, int yy) {
	
	if (state == GLUT_DOWN)  {
		startX = xx;
		startY = yy;
		if (button == GLUT_LEFT_BUTTON)
			tracking = 1;
		else if (button == GLUT_RIGHT_BUTTON)
			tracking = 2;
		else
			tracking = 0;
	}
	else if (state == GLUT_UP) {
		if (tracking == 1) {
			alpha += (xx - startX);
			beta += (yy - startY);
		}
		else if (tracking == 2) {
			
			r -= yy - startY;
			if (r < 3)
				r = 3.0;
		}
		tracking = 0;
	}
}


void processMouseMotion(int xx, int yy) {

	int deltaX, deltaY;
	int alphaAux, betaAux;
	int rAux;

	if (!tracking)
		return;

	deltaX = xx - startX;
	deltaY = yy - startY;

	if (tracking == 1) {


		alphaAux = alpha + deltaX;
		betaAux = beta + deltaY;

		if (betaAux > 85.0)
			betaAux = 85.0;
		else if (betaAux < -85.0)
			betaAux = -85.0;

		rAux = r;
	}
	else if (tracking == 2) {

		alphaAux = alpha;
		betaAux = beta;
		rAux = r - deltaY;
		if (rAux < 3)
			rAux = 3;
	}
	camX = rAux * sin(alphaAux * 3.14 / 180.0) * cos(betaAux * 3.14 / 180.0);
	camZ = rAux * cos(alphaAux * 3.14 / 180.0) * cos(betaAux * 3.14 / 180.0);
	camY = rAux * 							     sin(betaAux * 3.14 / 180.0);
}

void init() {
// 	Load the height map "terreno.jpg"
	// terreno.jpg is the image containing our height map
		ilLoadImage((ILstring)"./terreno.jpg");
	// convert the image to single channel per pixel
	// with values ranging between 0 and 255
		ilConvertImage(IL_LUMINANCE, IL_UNSIGNED_BYTE);
	// important: check tw and th values
	// both should be equal to 256
	// if not there was an error loading the image
	// most likely the image could not be found
		tw = ilGetInteger(IL_IMAGE_WIDTH);
		printf("%d\n",tw);
		th = ilGetInteger(IL_IMAGE_HEIGHT);
		printf("%d\n",th);
	// imageData is a LINEAR array with the pixel values
		imageData = ilGetData();
	// 	Build the vertex arrays
	std::vector<float> pontos;
	for (unsigned int altura=0;altura<th-1;altura++){
		for(unsigned int largura=0;largura<tw;largura++){
			printf("Largura:%d|Altura:%d\n",altura,largura);
			pontos.push_back(largura);
			pontos.push_back(imageData[altura*th+largura]);
			pontos.push_back(altura);

			pontos.push_back(largura);
			pontos.push_back(imageData[(altura+1)*th+largura]);
			pontos.push_back((altura + 1));
			

		}
	}
	glGenBuffers(1, buffers);
	glBindBuffer(GL_ARRAY_BUFFER,buffers[0]);
	glBufferData(GL_ARRAY_BUFFER,sizeof(float) * pontos.size(), pontos.data(), GL_STATIC_DRAW);
	
// 	OpenGL settings
	glEnable(GL_FILL);
}


int main(int argc, char **argv) {

// init GLUT and the window
	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_DEPTH|GLUT_DOUBLE|GLUT_RGBA);
	glutInitWindowPosition(100,100);
	glutInitWindowSize(320,320);
	glutCreateWindow("CG@DI-UM");

	glEnableClientState(GL_VERTEX_ARRAY);
	glPolygonMode(GL_FRONT, GL_LINE);

// Required callback registry 
	glutDisplayFunc(renderScene);
	glutIdleFunc(renderScene);
	glutReshapeFunc(changeSize);

// Callback registration for keyboard processing
	glutKeyboardFunc(processKeys);
	glutMouseFunc(processMouseButtons);
	glutMotionFunc(processMouseMotion);

	glewInit();
    ilInit();
	init();	

// enter GLUT's main cycle
	glutMainLoop();
	
	return 0;
}

