### Versão Firebase
import datetime
import firebase_admin
from firebase_admin import credentials,db
from pynput import mouse 

logNumber = 0 

cred = credentials.Certificate("/Users/goncalobraga/Desktop/FACULDADE/SI/Sensorização e Ambiente/Aula2/sistemasinteligentes-sa-firebase-adminsdk-i9zeb-7ccd2cdf17.json")
firebase_admin.initialize_app(cred,{"databaseURL":"https://sistemasinteligentes-sa-default-rtdb.firebaseio.com/"})

ref = db.reference("/")

f = open('loggerMouse.txt', 'a') 
def get_current_time():
    now = datetime.datetime.now()
    return now.strftime("%Y-%m-%d %H:%M:%S")

#detect mouse movement
def on_move(x, y):
    global logNumber
    print('Pointer moved to {0}'.format((x, y)))
    log = get_current_time() + '|' + "MouseMovement" + '|' + str((x, y)) + '\n'
    f.write(log)
    logKey = "Log_"+ str(logNumber)
    logNumber += 1
    db.reference("/").update({logKey:log})
    
   

#detect mouse scroll
def on_scroll(x, y, dx, dy):
    global logNumber
    print('Mouse scrolled at ({0}, {1})({2}, {3})'.format(x, y, dx, dy))
    log = get_current_time() + '|' + "MouseScrolled" + '|' + str((x,y)) + '->' +str((dx,dy))+'\n'
    f.write(log)
    logKey = "Log_"+ str(logNumber)
    logNumber+=1
    db.reference("/").update({logKey:log})
    

#detect mouse click
def on_click(x, y, button, pressed):
    global logNumber
    if pressed:
        print('Mouse clicked at ({0}, {1}) with {2}'.format(x, y, str(button)))
        log = get_current_time() + '|' + "MouseClicked" + '|' + str((x,y)) + 'with' +str(button)+'\n'
        f.write(log)
        logKey = "Log_"+ str(logNumber)
        logNumber+=1
        db.reference("/").update({logKey:log})
        if button == mouse.Button.right:
            #stop listener
                print('Gracefully Stopping!')
                return False

with mouse.Listener(
    on_move=on_move,
    on_click=on_click,
    on_scroll=on_scroll) as listener:
    listener.join()
    
f.close()
