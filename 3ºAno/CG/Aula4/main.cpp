#include <GL/glew.h> // before including glut.h
#ifdef __APPLE__
#include <GLUT/glut.h>
#else
#include <GL/glut.h>
#include <iostream>
#endif

#define _USE_MATH_DEFINES
#include <math.h>
#include <vector>

float alpha = 0.0;
float beta = 0.0;
int radium = 5.0;
int i = 0;
int k = 0;

float d_x=0.0;
float d_y=0.0;
float d_z=0.0;

GLuint vertices, verticeCount;

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

void prepareData(float radius, float height, int slices) {
	vertices=1;
 	std :: vector<float> p;
	float angle=(2*M_PI)/slices;

	for (int i=1;i<=slices;i++){
		float angle1=(i-1)*angle;
		float angle2=i*angle;

			p.push_back(0.0f);
			p.push_back(height/2);
			p.push_back(0.0f);   

			p.push_back(sin(angle1)*radius);
			p.push_back(height/2);
			p.push_back(cos(angle1)*radius);  

			p.push_back(sin(angle2)*radius);
			p.push_back(height/2);
			p.push_back(cos(angle2)*radius);  
		   
			p.push_back(0.0f);
			p.push_back(-height/2);
			p.push_back(0.0f);                           

			p.push_back(sin(angle1)*radius);
			p.push_back(-height/2);
			p.push_back(cos(angle1)*radius);
			
			p.push_back(sin(angle2)*radius);
			p.push_back(-height/2);
			p.push_back(cos(angle2)*radius);
	  
			p.push_back(sin(angle2)*radius);
			p.push_back(height/2);
			p.push_back(cos(angle2)*radius);   
			
			p.push_back(sin(angle1)*radius);
			p.push_back(height/2);
			p.push_back(cos(angle1)*radius);
			
			p.push_back(sin(angle1)*radius);
			p.push_back(-height/2);
			p.push_back(cos(angle1)*radius);

			p.push_back(sin(angle2)*radius);
			p.push_back(height/2);
			p.push_back(cos(angle2)*radius);
			 
			p.push_back(sin(angle1)*radius);
			p.push_back(-height/2);
			p.push_back(cos(angle1)*radius);
			
			p.push_back(sin(angle2)*radius);
			p.push_back(-height/2);
			p.push_back(cos(angle2)*radius);

	}
	verticeCount = p.size() / 3;

	glGenBuffers(1, &vertices);

	glBindBuffer(GL_ARRAY_BUFFER, vertices);
 	glBufferData(
 					GL_ARRAY_BUFFER, // tipo do buffer, só é relevante na altura do desenho
 					sizeof(float) * p.size(), // tamanho do vector em bytes
 					p.data(), // os dados do array associado ao vector
 					GL_STATIC_DRAW); // indicativo da utilização (estático e para desenho)
}
void drawCylinder(float radius, float height, int slices) {
	float angle=(2*M_PI)/slices;

	for (int i=1;i<=slices;i++){
		float angle1=(i-1)*angle;
		float angle2=i*angle;
		glBegin(GL_TRIANGLES);
			glColor3f(1.0f, 0.0f, 0.0f);
			glVertex3f(0.0f,height/2, 0.0f);                                 // Base Superior
			glVertex3f(sin(angle1)*radius,height/2, cos(angle1)*radius);
			glVertex3f(sin(angle2)*radius,height/2, cos(angle2)*radius);
		glEnd();
		
		glBegin(GL_TRIANGLES);
			glColor3f(1.0f, 0.0f, 0.0f);
			glVertex3f(0.0f,-height/2, 0.0f);                                // Base Inferior
			glVertex3f(sin(angle1)*radius,-height/2, cos(angle1)*radius);
			glVertex3f(sin(angle2)*radius,-height/2, cos(angle2)*radius);
		glEnd();
		glBegin(GL_TRIANGLES);
			glColor3f(0.0f, 1.0f, 0.0f);
			glVertex3f(sin(angle2)*radius,height/2, cos(angle2)*radius);     // Lateral           
			glVertex3f(sin(angle1)*radius,height/2, cos(angle1)*radius);
			glVertex3f(sin(angle1)*radius,-height/2, cos(angle1)*radius);
		glEnd();
		glBegin(GL_TRIANGLES);
			glColor3f(0.0f, 0.0f, 1.0f);
			glVertex3f(sin(angle2)*radius,height/2, cos(angle2)*radius); 
			glVertex3f(sin(angle1)*radius,-height/2, cos(angle1)*radius);     // Lateral
			glVertex3f(sin(angle2)*radius,-height/2, cos(angle2)*radius); 
		glEnd();
	}
}
// Explorer Mode Camera 
void teclas (unsigned char key, int x, int y){
	if (key == 'd'){ 
		alpha = (i/32.)* M_PI;
		i++;
	}
	if (key == 'a') {
		alpha = -(i/32.)* M_PI;
		i++;
	}

	if (key == 's' && k<16){
		beta = (k/32.)* M_PI;
		k--;
	}
	if (key == 'w' && k>-16){
		beta = (k/32.)* M_PI;
		k++;
	}

	if (key == 'q'){
		radium = radium + 1;
	}
	if (key == 'e'){
		radium = radium - 1;
	}

	glutPostRedisplay();
}

void renderScene(void) {

	// clear buffers
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	// set the camera
	glLoadIdentity();
	
	gluLookAt(radium*cos(beta)*sin(alpha),radium*sin(beta),radium*cos(beta)*cos(alpha), 
		      0.0,0.0,0.0,
			  0.0f,1.0f,0.0f);

	drawCylinder(1,2,10);

	// End of frame
	glutSwapBuffers();
}


int main(int argc, char **argv) {

// init GLUT and the window
	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_DEPTH|GLUT_DOUBLE|GLUT_RGBA);
	glutInitWindowPosition(100,100);
	glutInitWindowSize(800,800);
	glutCreateWindow("CG@DI-UM");
	glewInit(); // after glutCreateWindow and before calling any OpenGL function
// Enable Buffer Functionality
	glEnableClientState(GL_VERTEX_ARRAY);		
// Required callback registry 
	glutDisplayFunc(renderScene);
	glutReshapeFunc(changeSize);
// Callback registration for keyboard processing
	glutKeyboardFunc(teclas);
	// glutSpecialFunc(processSpecialKeys);
//  OpenGL settings
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_CULL_FACE);
	glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
// enter GLUT's main cycle
	glutMainLoop();
	
	return 1;
}
