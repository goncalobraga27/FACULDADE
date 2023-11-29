package src;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

import static java.lang.Integer.parseInt;
class Register {
    private int sum;
    private int nRecebidos;

    public Register(){
        this.sum=0;
        this.nRecebidos=0;
    }

    public void add(int value){
        this.sum+=value;
        this.nRecebidos++;
    }
    public double media(){
        return (double) this.sum/this.nRecebidos;
    }
    public int getSum(){
        return this.sum;
    }
}
class ServerWorker implements Runnable {
    private Socket socket;
    private final Register reg;

    private final Lock l=new ReentrantLock();


    public ServerWorker(Socket s,Register reg) {
        this.socket = s;
        this.reg=reg;
    }

    public void run() {
        try {
            this.l.lock();
            BufferedReader in = new BufferedReader(new InputStreamReader(this.socket.getInputStream()));
            PrintWriter out = new PrintWriter(this.socket.getOutputStream());

            String line;
            while ((line = in.readLine()) != null) {
                this.reg.add(parseInt(line));
                double media =this.reg.media();
                out.println(media);
                out.flush();
            }
            this.socket.shutdownInput();
            this.socket.shutdownOutput();
            this.socket.close();
            this.l.unlock();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}

public class EchoServer {

    public static void main(String[] args) {
        try {
            ServerSocket ss = new ServerSocket(12345);
            Register reg=new Register();
            while (true) {
                Socket socket = ss.accept();
                Thread worker=new Thread(new ServerWorker(socket,reg));
                worker.start();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}