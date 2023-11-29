package src;
import java.util.concurrent.locks.*;
/* Uma barreira serve para sincronizar a execução de todas as threads
Depois de passar a barreira as threads começam a execução todas ao mesmo tempo
 */
// Aqui o lock tem de possuir quais as condições que faz o lock ser adquirido
public class Barrier {
    private Lock l= new ReentrantLock();
    private Condition c= l.newCondition();
    public static int state=0; // sendo o state o número de threads que se encontram suspensas
    final int N;
    int out=0;
    int stage=0;

    public Barrier(int N){
        this.N=N;
    }
    // Barrier móvel
    void await() throws InterruptedException {
        this.l.lock();
        try{
            while(out!=0)
                c.await();

            state++;
            if (state < this.N) {
                while (state < this.N) {
                    c.await();
                }
            } else {
                c.signalAll();

            }
            out+=1;
            if (out==N){
                state=0;
                out=0;
                c.signalAll();
            }
        }
        finally {
            this.l.unlock();
        }
    }
    // Outra implementação da barreira móvel
    void await2() throws InterruptedException {
        this.l.lock();
        try{
            final int temp=this.stage;
            state++;
            if (state < this.N) {
                while (temp==this.stage) {
                    c.await();
                }
            } else {
                this.stage+=1;
                state=0;
                c.signalAll();

            }
        }
        finally {
            this.l.unlock();
        }
    }
// Método await que resolve a oergunta 1.1 do guião 4
    void await1() throws InterruptedException {
        this.l.lock();
        try{
                state++;
                if (state < this.N) {
                    while (state < this.N) {
                        c.await();
                    }
                } else {
                    c.signalAll();
                }
        }
        finally {
            this.l.unlock();
        }
    }
}

