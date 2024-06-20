import time
from spade.agent import Agent
from spade.behaviour import OneShotBehaviour
from spade.message import Message

class SenderAgent(Agent):
    class Behaviour(OneShotBehaviour):
        async def run(self):
            print("Behaviour running...")
            msg = Message(to="receiver_agent@air-de-goncalo.home") # Instantiate the message
            msg.set_metadata("performative", "inform")   # Set the "inform" FIPA performative
            msg.set_metadata("ontology", "myOntology")   # Set the ontology of the message content
            msg.set_metadata("language", "OWL-S")        # Set the language of the message content
            msg.body = "Hello World!"

            # Send message
            await self.send(msg)
            print("Message sent!") 

            # set exit_code for the behaviour
            self.exit_code = "Job Finished!"

            # stop agent from behaviour
            await self.agent.stop()

    async def setup(self):
        print("SenderAgent started")
        self.b = self.Behaviour()
        self.add_behaviour(self.b)

if __name__ == "__main__":
    agent = SenderAgent("sender_agent@air-de-goncalo.home", "NOPASSWORD")
    future = agent.start()  
    future.result()        

    while agent.is_alive():
        try:
            time.sleep(1)
        except KeyboardInterrupt:
            agent.stop()
            break
    
    print("Agent finished with exit code: {}".format(agent.b.exit_code))