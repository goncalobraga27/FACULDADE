import java.io.*;
import java.net.Socket;
import java.util.concurrent.locks.ReentrantLock;

public class FramedConnection implements AutoCloseable {
    private final Socket sck;
    private final DataInputStream is;
    private final DataOutputStream os;

    private final ReentrantLock sendLock= new ReentrantLock();
    private  final ReentrantLock receiveLock= new ReentrantLock();
    public FramedConnection(Socket socket) throws IOException {
            this.sck=socket;
            this.is= new DataInputStream(new BufferedInputStream(this.sck.getInputStream()));
            this.os= new DataOutputStream(new BufferedOutputStream((this.sck.getOutputStream())));

    }
    public void send(byte[] data) throws IOException {
        this.sendLock.lock();
        try {
                this.os.writeInt(data.length);
                this.os.write(data);
                this.os.flush();
        }
        finally {
            this.sendLock.unlock();
        }
    }
    public byte[] receive() throws IOException {
        this.receiveLock.lock();
        byte[] data;
        try {
            int size = this.is.readInt();
            data = new byte[size];
            this.is.readFully(data);
        }
        finally {
            this.receiveLock.unlock();
        }
        return data;
    }
    public void close() throws IOException {
        this.sck.close();
    }
}
