### Versão Adafruit
import datetime
from Adafruit_IO import Client,Data,Feed
from pynput import mouse 

aio = Client("goncalobraga27","aio_LbfZ36Fskc3foUKywgkWURyNKWFa")

f = open('loggerMouse.txt', 'a') 
def get_current_time():
    now = datetime.datetime.now()
    return now.strftime("%Y-%m-%d %H:%M:%S")

#detect mouse movement
def on_move(x, y):
    print('Pointer moved to {0}'.format((x, y)))
    log = get_current_time() + '|' + "MouseMovement" + '|' + str((x, y)) + '\n'
    f.write(log)
    feed = aio.feeds('sensorfeed')
    aio.send_data(feed.key,log)

#detect mouse scroll
def on_scroll(x, y, dx, dy):
    print('Mouse scrolled at ({0}, {1})({2}, {3})'.format(x, y, dx, dy))
    log = get_current_time() + '|' + "MouseScrolled" + '|' + str((x,y)) + '->' +str((dx,dy))+'\n'
    f.write(log)
    feed = aio.feeds('sensorfeed')
    aio.send_data(feed.key,log)

#detect mouse click
def on_click(x, y, button, pressed):
    if pressed:
        print('Mouse clicked at ({0}, {1}) with {2}'.format(x, y, str(button)))
        log = get_current_time() + '|' + "MouseClicked" + '|' + str((x,y)) + 'with' +str(button)+'\n'
        f.write(log)
        feed = aio.feeds('sensorfeed')
        aio.send_data(feed.key,log)
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
