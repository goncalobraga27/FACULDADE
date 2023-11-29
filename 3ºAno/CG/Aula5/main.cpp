#include <stdio.h>
#include <stdlib.h>

#ifdef __APPLE__
#include <GLUT/glut.h>
#else
#include <GL/glut.h>
#endif

#define _USE_MATH_DEFINES
#include <math.h>

float alfa = 0.0f, beta = 0.5f, radius = 100.0f;
float camX, camY, camZ;


void spherical2Cartesian() {

	camX = radius * cos(beta) * sin(alfa);
	camY = radius * sin(beta);
	camZ = radius * cos(beta) * cos(alfa);
}


void changeSize(int w, int h) {

	// Prevent a divide by zero, when window is too short
	// (you cant make a window with zero width).
	if(h == 0)
		h = 1;

	// compute window's aspect ratio 
	float ratio = w * 1.0 / h;

	// Set the projection matrix as current
	glMatrixMode(GL_PROJECTION);
	// Load Identity Matrix
	glLoadIdentity();
	
	// Set the viewport to be the entire window
    glViewport(0, 0, w, h);

	// Set perspective
	gluPerspective(45.0f ,ratio, 1.0f ,1000.0f);

	// return to the model view matrix mode
	glMatrixMode(GL_MODELVIEW);
}



void renderScene(void) {

	// clear buffers
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	// set the camera
	glLoadIdentity();
	gluLookAt(camX, camY, camZ,
		0.0, 0.0, 0.0,
		0.0f, 1.0f, 0.0f);

	glColor3f(0.2f, 0.8f, 0.2f);
	glBegin(GL_TRIANGLES);
		glVertex3f(100.0f, 0, -100.0f);
		glVertex3f(-100.0f, 0, -100.0f);
		glVertex3f(-100.0f, 0, 100.0f);

		glVertex3f(100.0f, 0, -100.0f);
		glVertex3f(-100.0f, 0, 100.0f);
		glVertex3f(100.0f, 0, 100.0f);
	glEnd();

	int arvoresNaCena=0;
	srand(3);

	while(arvoresNaCena != 350){
		float y = 0.0f;
		float xDesNormalized=(double)rand()/(double)RAND_MAX;
		float zDesNormalized=(double)rand()/(double)RAND_MAX;
		printf("XDesNormalized->%f\n",xDesNormalized);
		printf("ZDesNormalized->%f\n",zDesNormalized);
		float x = xDesNormalized*(double)200-(double)100;
		float z = zDesNormalized*(double)200-(double)100;
		printf("X->%f\n",x);
		printf("Z->%f\n",z);
		int secondMember= pow(50,2);
		int firstMember= pow(x,2)+ pow(z,2);
		if(firstMember>=secondMember){
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
	// Desenho do donuts
	glPushMatrix();
	glColor3f(1.0f,0.0f,0.0f);
	glutSolidTorus(1,5,15,15);
	glPopMatrix();

	int numberTeaPot=8;
	float alpha=2*M_PI/numberTeaPot;

	for(int i=0;i<8;i++){
		float alphaU=i*alpha;
		float alphaAng=(float)(alphaU*180)/(float)M_PI;
		printf("Ângulo no momento->%f\n",alphaU);
		glPushMatrix();
		glRotatef(alphaAng,0.0f,1.0f,0.0f);
		glPushMatrix();
		glTranslatef(0.0f,3.0f,0.0f);
		glPushMatrix();
		glTranslatef(sin(alphaAng)*15,0.0f,cos(alphaAng)*15);
		glColor3f(0.0f,0.0f,1.0f);
		glutSolidTeapot(2);
		glPopMatrix();
		glPopMatrix();
		glPopMatrix();
	
	}

	int numberTeaPotF=36;
	float alphaF=2*M_PI/numberTeaPotF;

	for(int i=0;i<36;i++){
		float alphaUF=i*alpha;
		float alphaAngF=(float)(alphaUF*180)/(float)M_PI;
		printf("Ângulo no momento(F)->%f\n",alphaUF);
		glPushMatrix();
		glTranslatef(0.0f,3.0f,0.0f);
		glPushMatrix();
		glTranslatef(sin(alphaUF)*35,0.0f,cos(alphaUF)*35);
		glColor3f(1.0f,0.0f,0.0f);
		glutSolidTeapot(2);
		glPopMatrix();
		glPopMatrix();
		glPopMatrix();
	
	}
	
	glutSwapBuffers();
}


void processKeys(unsigned char c, int xx, int yy) {

// put code to process regular keys in here

}


void processSpecialKeys(int key, int xx, int yy) {

	switch (key) {

	case GLUT_KEY_RIGHT:
		alfa -= 0.1; break;

	case GLUT_KEY_LEFT:
		alfa += 0.1; break;

	case GLUT_KEY_UP:
		beta += 0.1f;
		if (beta > 1.5f)
			beta = 1.5f;
		break;

	case GLUT_KEY_DOWN:
		beta -= 0.1f;
		if (beta < -1.5f)
			beta = -1.5f;
		break;

	case GLUT_KEY_PAGE_DOWN: radius -= 1.0f;
		if (radius < 1.0f)
			radius = 1.0f;
		break;

	case GLUT_KEY_PAGE_UP: radius += 1.0f; break;
	}
	spherical2Cartesian();
	glutPostRedisplay();

}


void printInfo() {

	printf("Vendor: %s\n", glGetString(GL_VENDOR));
	printf("Renderer: %s\n", glGetString(GL_RENDERER));
	printf("Version: %s\n", glGetString(GL_VERSION));

	printf("\nUse Arrows to move the camera up/down and left/right\n");
	printf("Home and End control the distance from the camera to the origin");
}


int main(int argc, char **argv) {

// init GLUT and the window
	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_DEPTH|GLUT_DOUBLE|GLUT_RGBA);
	glutInitWindowPosition(100,100);
	glutInitWindowSize(800,800);
	glutCreateWindow("CG@DI-UM");
		
// Required callback registry 
	glutDisplayFunc(renderScene);
	glutReshapeFunc(changeSize);
	
// Callback registration for keyboard processing
	glutKeyboardFunc(processKeys);
	glutSpecialFunc(processSpecialKeys);

//  OpenGL settings
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_CULL_FACE);

	spherical2Cartesian();

	printInfo();

// enter GLUT's main cycle
	glutMainLoop();
	
	return 1;
}
