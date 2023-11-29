public class Main {
    public static void main(String[] args) {
        Thread t0=new Thread(new Increment());
        Thread t1=new Thread(new Increment());
        Thread t2=new Thread(new Increment());
        Thread t3=new Thread(new Increment());
        Thread t4=new Thread(new Increment());
        Thread t5=new Thread(new Increment());
        Thread t6=new Thread(new Increment());
        Thread t7=new Thread(new Increment());
        Thread t8=new Thread(new Increment());
        Thread t9=new Thread(new Increment());
        t0.start();t1.start();t2.start();t3.start();t4.start();t5.start();t6.start();t7.start();t8.start();t9.start();
        try{
            t0.join();
            System.out.println("Fim da thread 0");
        }
        catch (Exception e){
            System.out.println("ERRO na thread 0");
        }

        try{
            t1.join();
            System.out.println("Fim da thread 1");
        }
        catch (Exception e){
            System.out.println("ERRO na thread 1");
        }
        try{
            t2.join();
            System.out.println("Fim da thread 2");
        }
        catch (Exception e){
            System.out.println("ERRO na thread 2");
        }
        try{
            t3.join();
            System.out.println("Fim da thread 3");
        }
        catch (Exception e){
            System.out.println("ERRO na thread 3");
        }
        try{
            t4.join();
            System.out.println("Fim da thread 4");
        }
        catch (Exception e){
            System.out.println("ERRO na thread 4");
        }
        try{
            t5.join();
            System.out.println("Fim da thread 5");
        }
        catch (Exception e){
            System.out.println("ERRO na thread 5");
        }
        try{
            t6.join();
            System.out.println("Fim da thread 6");
        }
        catch (Exception e){
            System.out.println("ERRO na thread 6");
        }
        try{
            t7.join();
            System.out.println("Fim da thread 7");
        }
        catch (Exception e){
            System.out.println("ERRO na thread 7");
        }
        try{
            t8.join();
            System.out.println("Fim da thread 8");
        }
        catch (Exception e){
            System.out.println("ERRO na thread 8");
        }
        try{
            t9.join();
            System.out.println("Fim da thread 9");
        }
        catch (Exception e){
            System.out.println("ERRO na thread 9");
        }
        System.out.println("FIM");
    }
}