import java.util.concurrent.locks.*;
class Bank {

    private static class Account {
        private int balance;
        Lock l = new ReentrantLock();
        Account(int balance) {
            this.balance = balance;
        }

        int balance() {
            return balance;
        }

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

    // Bank slots and vector of accounts
    private int slots;
    private Account[] av;

    Lock l= new ReentrantLock();
    public Bank(int n) {
        slots = n;
        av = new Account[slots];
        for (int i = 0; i < slots; i++) av[i] = new Account(0);
    }

    // Account balance
    public int balance(int id) {
        if (id < 0 || id >= slots)
            return 0;
        Account ac= av[id];
        ac.l.lock();
        try {
            return av[id].balance();
        }
        finally {
            ac.l.unlock();
        }
    }

    // Deposit
    public boolean deposit(int id, int value) {
        if (id < 0 || id >= slots)
            return false;
        Account ac=av[id];
        ac.l.lock();
        try {
            return av[id].deposit(value);
        }
        finally {
            ac.l.unlock();
        }
    }

    // Withdraw; fails if no such account or insufficient balance
    public boolean withdraw(int id, int value) {
        if (id < 0 || id >= slots)
            return false;
        Account ac= av[id];
        ac.l.lock();
        try {
            return av[id].withdraw(value);
        }
        finally {
            ac.l.unlock();
        }
    }

    public boolean transfer (int from, int to, int value){
        if (from<0 || from >=slots || to <0 || to>=slots) return false;
        Boolean b;
        l.lock();
        Account ac1=av[from];
        Account ac2=av[to];
        if (from<to) {
            ac1.l.lock();
            ac2.l.lock();
        }
        else {
            ac2.l.lock();
            ac1.l.lock();
        }
        try {
            try {
               b = ac1.withdraw(value);
            }
            finally {
                ac1.l.unlock();
            }
            if (b == false) return false;
            else {
                try {
                    ac2.deposit(value);
                }
                finally{
                    ac2.l.unlock();
                }
                return true;
            }
        }
        finally {
            l.unlock();
        }

    }
    public int totalBalance(){
        int valorTotalDep = 0;
        for (int i = 0; i < slots; i++) {
            av[i].l.lock();
        }
        for (int i = 0; i < slots; i++) {
            try {
                valorTotalDep += av[i].balance();
            }
            finally {
                av[i].l.unlock();
            }
        }
        return valorTotalDep;
    }
}