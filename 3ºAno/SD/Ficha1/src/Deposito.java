import java.util.concurrent.locks.Lock;

public class Deposito implements Runnable {
    private final int quantDep;
    private final int valor;
    private final Bank b;

    private final Lock l;
    public Deposito(int qDep,int valor,Bank bk,Lock l){
        this.quantDep=qDep;
        this.valor=valor;
        this.b=bk;
        this.l=l;
    }
    public void run(){
        for(int i=0;i<quantDep;i++){
            l.lock();
            try{
                this.b.deposit(this.valor);
            }
            finally {
                l.unlock();
            }
        }
    }
}
