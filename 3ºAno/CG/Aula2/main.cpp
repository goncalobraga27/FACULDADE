#ifdef __APPLE__
#include <GLUT/glut.h>
#else
#include <GL/glut.h>
#endif

#include <math.h>
float translation_x=0.0;
float translation_y=0.0;
float translation_z=0.0;
float angle=0;
float altura=1.5;
float mode=GL_FILL;

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
	gluLookAt(5.0,5.0,5.0, 
		      0.0,0.0,0.0,
			  0.0f,1.0f,0.0f);

	// put the geometric transformations here
	glBegin(GL_LINES);
		// X axis in red
		glColor3f(1.0f, 0.0f, 0.0f);
		glVertex3f(-100.0f, 0.0f, 0.0f);
		glVertex3f( 100.0f, 0.0f, 0.0f);
		// Y Axis in Green
		glColor3f(0.0f, 1.0f, 0.0f);
		glVertex3f(0.0f,-100.0f, 0.0f);
		glVertex3f(0.0f, 100.0f, 0.0f);
		// Z Axis in Blue
		glColor3f(0.0f, 0.0f, 1.0f);
		glVertex3f(0.0f, 0.0f,-100.0f);
		glVertex3f(0.0f, 0.0f, 100.0f);
	glEnd();

	glTranslatef(translation_x,translation_y,translation_z);
	glRotatef(angle,0,1,0);
	glPolygonMode(GL_FRONT,mode);
	// put drawing instructions here
	glBegin(GL_TRIANGLES);
		glColor3f(1.0f, 0.0f, 0.0f);
		glVertex3f(0.0f, 1.0f, 0.0f);
		glVertex3f(1.0, 0.0f, 1.0f);
		glVertex3f(1.0f, 0.0f, -1.0f);
	glEnd();
	
	glBegin(GL_TRIANGLES);
		glColor3f(0.0f, 1.0f, 0.0f);
		glVertex3f(0.0f, 1.0f, 0.0f);
		glVertex3f(-1.0f, 0.0f, 1.0f);
		glVertex3f(1.0f, 0.0f, 1.0f);
	glEnd();

	glBegin(GL_TRIANGLES);
		glColor3f(0.0f, 0.0f, 1.0f);
		glVertex3f(0.0f, 1.0f, 0.0f);
		glVertex3f(-1.0f, 0.0f, -1.0f);
		glVertex3f(-1.0f, 0.0f, 1.0f);
	glEnd();

	glBegin(GL_TRIANGLES);
		glColor3f(1.0f, 0.5f, 1.0f);
		glVertex3f(0.0f, 1.0f, 0.0f);
		glVertex3f(1.0f, 0.0f, -1.0f);
		glVertex3f(-1.0f, 0.0f, -1.0f);
	glEnd();

	// End of frame
	glutSwapBuffers();
}



// write function to process keyboard events


void teclas (unsigned char key, int x, int y){
	if (key == 'd') translation_x = translation_x + 0.1;
	if (key == 'a') translation_x = translation_x - 0.1;

	if (key == 's') translation_z = translation_z + 0.1;
	if (key == 'w') translation_z = translation_z - 0.1;

	if (key == 'q') angle+=30;
	if (key == 'e') angle-=30;

	if(key == 'm') altura +=0.1;
	if(key == 'n') altura -=0.1;
	 

	if(key == '1') mode = GL_FILL;
	if(key == '2') mode = GL_LINE;
	if(key == '3') mode = GL_POINT;
	
	glutPostRedisplay();
}

	
void update(int value){
	float _angle=2.0f;
	if(_angle>360.f){
		_angle-=360;
	}
	glutPostRedisplay();
	glutTimerFunc(25,update,0);
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

	
// put here the registration of the keyboard callbacks
	glutKeyboardFunc(teclas);


//  OpenGL settings
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_CULL_FACE);
	
// enter GLUT's main cycle
	glutMainLoop();
	
	return 1;
}
