import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

public class MainJava {
    public static void main(String[] args) {
        Bank b = new Bank();
        Lock l = new ReentrantLock();
        Thread t0=new Thread(new Deposito(1000,100,b,l));
        Thread t1=new Thread(new Deposito(1000,100,b,l));
        Thread t2=new Thread(new Deposito(1000,100,b,l));
        Thread t3=new Thread(new Deposito(1000,100,b,l));
        Thread t4=new Thread(new Deposito(1000,100,b,l));
        Thread t5=new Thread(new Deposito(1000,100,b,l));
        Thread t6=new Thread(new Deposito(1000,100,b,l));
        Thread t7=new Thread(new Deposito(1000,100,b,l));
        Thread t8=new Thread(new Deposito(1000,100,b,l));
        Thread t9=new Thread(new Deposito(1000,100,b,l));
        t0.start();t1.start();t2.start();t3.start();t4.start();t5.start();t6.start();t7.start();t8.start();t9.start();
        try{
            t0.join();
        }
        catch (Exception e){
            System.out.println("ERRO na thread 0");
        }

        try{
            t1.join();

        }
        catch (Exception e){
            System.out.println("ERRO na thread 1");
        }
        try{
            t2.join();

        }
        catch (Exception e){
            System.out.println("ERRO na thread 2");
        }
        try{
            t3.join();

        }
        catch (Exception e){
            System.out.println("ERRO na thread 3");
        }
        try{
            t4.join();

        }
        catch (Exception e){
            System.out.println("ERRO na thread 4");
        }
        try{
            t5.join();

        }
        catch (Exception e){
            System.out.println("ERRO na thread 5");
        }
        try{
            t6.join();

        }
        catch (Exception e){
            System.out.println("ERRO na thread 6");
        }
        try{
            t7.join();

        }
        catch (Exception e){
            System.out.println("ERRO na thread 7");
        }
        try{
            t8.join();

        }
        catch (Exception e){
            System.out.println("ERRO na thread 8");
        }
        try{
            t9.join();
        }
        catch (Exception e){
            System.out.println("ERRO na thread 9");
        }
        l.lock();
        try {
            System.out.println("O saldo bancário é:" + b.balance());
        }
        finally {
            l.unlock();
        }
    }
}