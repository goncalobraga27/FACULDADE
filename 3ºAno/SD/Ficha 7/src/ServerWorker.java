package src;
import java.io.*;
import java.net.Socket;
import java.util.stream.Stream;

import static java.lang.Integer.parseInt;


class ServerWorker implements Runnable {
    private Socket socket;
    private ContactManager manager;

    public ServerWorker(Socket socket, ContactManager manager) {
        this.socket = socket;
        this.manager = manager;
    }

    // @TODO
    @Override
    public void run() {
        try {
            DataInputStream in = new DataInputStream(socket.getInputStream());
            DataOutputStream out = new DataOutputStream(socket.getOutputStream());
            while(true){
                this.manager.getContacts().serialize(out);
                out.flush();
                Contact c = Contact.deserialize(in);
                this.manager.update(c);
                System.out.println(this.manager.getContacts());
            }
        }
        catch (Exception e){
            System.out.println("Problema na leitura do socket");
        }
        try {
            socket.close();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }

    }
}
