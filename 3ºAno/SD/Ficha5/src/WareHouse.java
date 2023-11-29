package src;
import java.util.*;
import java.util.concurrent.locks.*;

class Warehouse {
    private final Map<String, Product> map =  new HashMap<>();
    private final Lock l = new ReentrantLock();

    private class Product {
        private final Condition cP=l.newCondition();
        int quantity = 0; }

    private Product get(String item) {
            Product p = map.get(item);
            if (p != null) return p;
            p = new Product();
            map.put(item, p);
            return p;

    }
    
    // Metodo da forma egoísta
    public void supply(String item, int quantity) {
        this.l.lock();
        try {
            Product p = get(item);
            p.quantity += quantity;
            p.cP.signalAll();
        } finally {
            this.l.unlock();
        }
    }

    // Método da forma egoísta
    public void consume(Set<String> items){
        this.l.lock();
        try {
            for (String s : items) {
                while (get(s).quantity==0) {
                    get(s).cP.await();
                }
                get(s).quantity--;
            }
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        } finally {
            this.l.unlock();
        }
    }
    // Método da forma cooperativa
    public void consumeCoop(Set<String> items){
        this.l.lock();
        try {
            int n = items.size();
            Product [] ps = new Product[n];
            int i=0;
            for (String s : items) {
                ps[i]=get(s);
                i+=1;
            }

            i=0;
            while(i<n){
               Product p=ps[i];
                i++;
               if(p.quantity==0){
                   p.cP.await();
                   i=0;
               }
            }

        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        } finally {
            this.l.unlock();
        }
    }
}

