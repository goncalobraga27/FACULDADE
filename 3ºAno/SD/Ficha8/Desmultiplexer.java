
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.ReentrantLock;

public class Desmultiplexer implements AutoCloseable {
    private Map<Integer, List<byte[]> > filas;
    private TaggedConnection connection;
    private ReentrantLock WriteQueueLock= new ReentrantLock();
    private Condition wakeupThreads= WriteQueueLock.newCondition();
    private Exception tudobem;


    public Desmultiplexer(TaggedConnection conn) {
                this.connection=conn;
                this.filas=new HashMap<>();
    }
    public void start(){
        Runnable worker=(()->{
            try {
                this.WriteQueueLock.lock();
                TaggedConnection.Frame fRecebido=this.connection.receive();
                try{
                    List<byte []> listaDados=this.filas.get(fRecebido.tag);
                    listaDados.add(fRecebido.data);
                    this.filas.put(fRecebido.tag,listaDados);
                    this.wakeupThreads.signal();
                }
                finally {
                    this.WriteQueueLock.unlock();
                }

            }
            catch (Exception e){
                System.out.println("Erro na thread de leitura do socket");
            }
        });
        new Thread(worker).start();
    }
    public void send(TaggedConnection.Frame frame) throws IOException {
        this.connection.send(frame);
    }
    public void send(int tag, byte[] data) throws IOException {
       this.connection. send(tag, data);
    }
    public byte[] receive(int tag) throws IOException, InterruptedException {  // Este receive serve para cada thread ir buscar os seus bytes do buffer que tem como chave a sua tag
        this.WriteQueueLock.lock();
        try {
            List<byte[]> listaConteudo = this.filas.get(tag);
            while (listaConteudo.size() == 0 && this.tudobem!=null) {
                this.wakeupThreads.await();
            }
            byte[] fLida = new byte[0];
            if (listaConteudo.size() != 0) {
                fLida = listaConteudo.get(0);
            }
            return fLida;
        }
        finally {
            this.WriteQueueLock.unlock();
        }
    }
    public void close() throws IOException {
        this.connection.close();
    }

    /*
    O que é suposto é criar um desmultiplexador.
    Este desmultiplexador cria buffers por thread .
    A thread vai ver ao buffer a mensagem.
    Enquanto que não está lá nada a thread tem de esperar
    Caso exista casos de erros ele não faz mais nada
     */
}