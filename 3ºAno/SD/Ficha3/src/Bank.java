import java.util.*;
import java.util.concurrent.locks.*;

class Bank {

    private static class Account {
        private int balance;
        Lock lC=new ReentrantLock();
        Account(int balance) { this.balance = balance; }
        int balance() { return balance; }
        boolean deposit(int value) {
            balance += value;
            return true;
        }
        boolean withdraw(int value) {
            if (value > balance)
                return false;
            balance -= value;
            return true;
        }
    }

    private Map<Integer, Account> map = new HashMap<Integer, Account>();
    private int nextId = 0;
    Lock lB = new ReentrantLock();

    // create account and return account id
    public int createAccount(int balance) {
        int id;
        Account c = new Account(balance);
        lB.lock();
        try {
            id = nextId;
            nextId += 1;
            map.put(id, c);
        }
        finally {
            lB.unlock();
        }
        return id;
    }

    // close account and return balance, or 0 if no such account
    public int closeAccount(int id) {
        Account c=null;
        lB.lock();
        try {
            c = map.remove(id);
            if (c == null)
                return 0;
            else c.lC.lock();
        }
        finally {
            lB.unlock();
        }
        try {
            return c.balance();
        }
        finally {
            c.lC.unlock();
        }
    }

    // account balance; 0 if no such account
    public int balance(int id) {
        Account c;
        lB.lock();
        try {
          c = map.get(id);
            if (c == null)
                return 0;
            else c.lC.lock();
        }
        finally {
            lB.unlock();
        }
        try {
            return c.balance();
        }
        finally {
            c.lC.unlock();
        }
    }


    // deposit; fails if no such account
    public boolean deposit(int id, int value) {
        lB.lock();
        try {
            Account c = map.get(id);
            c.lC.lock();
            try {
                if (c == null)
                    return false;
                return c.deposit(value);
            }
            finally {
                c.lC.unlock();
            }
        }
        finally {
            lB.unlock();
        }
    }

    // withdraw; fails if no such account or insufficient balance
    public boolean withdraw(int id, int value) {
        Account c = map.get(id);
        if (c == null)
            return false;
        return c.withdraw(value);
    }

    // transfer value between accounts;
    // fails if either account does not exist or insufficient balance
    public boolean transfer(int from, int to, int value) {
        Boolean cf,ct;
        Account cfrom, cto;
        lB.lock();
        try {
            cfrom = map.get(from);
            cto = map.get(to);
            if (cfrom == null || cto ==  null)
                return false;
            cfrom.lC.lock();
            cto.lC.lock();
        }
        finally {
            lB.unlock();
        }
        try {
            cf=cfrom.withdraw(value);
        }
        finally {
            cfrom.lC.unlock();
        }
        try {
            ct=cto.deposit(value);
        }
        finally {
            cto.lC.unlock();
        }
        return  cf && ct;
    }

    // sum of balances in set of accounts; 0 if some does not exist
    public int totalBalance(int[] ids) {
        int total = 0;
        Account c;
        lB.lock();
        for (int i : ids) {
            try {
                c = map.get(i);
                if (c == null)
                    return 0;
                c.lC.lock();
            }
            finally {
                lB.unlock();
            }
            try {
                total += c.balance();
            }
            finally {
                c.lC.unlock();
            }

       }
        return total;
    }

}