import time, threading
from Agents.receiver import ReceiverAgent
from Agents.sender import SenderAgent
from spade.agent import Agent
from spade.behaviour import CyclicBehaviour
from spade.behaviour import OneShotBehaviour
from spade.message import Message

def wait_receiver():
    try:
        while True:
            time.sleep(100)
    except KeyboardInterrupt:
        print("Stopping...")

    receiver_agent.stop()

def wait_sender():
    while sender_agent.is_alive():
        try:
            time.sleep(100)
        except KeyboardInterrupt:
            sender_agent.stop()
            break
    
    print("Sender agent finished with exit code: {}".format(sender_agent.b.exit_code))

# Create and initialize Receiver Agent
receiver_agent = ReceiverAgent("receiver_agent@air-de-goncalo.home", "NOPASSWORD")
future = receiver_agent.start()
future.result()

print("Wait until user interrupts with ctrl+C")

# Create and initialize Sender Agent
sender_agent = SenderAgent("sender_agent@air-de-goncalo.home", "NOPASSWORD")
future = sender_agent.start()  
future.result()       

# Wait for the sender and receiver to end
t1 = threading.Thread(target=wait_receiver)
t2 = threading.Thread(target=wait_sender)

t1.start()
t2.start()

t1.join()
t2.join()