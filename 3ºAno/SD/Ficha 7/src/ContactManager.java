package src;

import java.util.HashMap;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

import static java.util.Arrays.asList;

class ContactManager {
    private HashMap<String, Contact> contacts;
    private Lock l=new ReentrantLock();

    public ContactManager() {
        contacts = new HashMap<>();
        // example pre-population
        this.update(new Contact("John", 20, 253123321, null, asList("john@mail.com")));
        this.update(new Contact("Alice", 30, 253987654, "CompanyInc.", asList("alice.personal@mail.com", "alice.business@mail.com")));
        this.update(new Contact("Bob", 40, 253123456, "Comp.Ld", asList("bob@mail.com", "bob.work@mail.com")));
    }


    // @TODO
    public void update(Contact c) {
        this.l.lock();
        try{
            if (this.contacts.containsKey(c.name())==true){
                this.contacts.replace(c.name(),c);
            }
            else {
                this.contacts.put(c.name(),c);
            }
        }
        finally {
            this.l.unlock();
        }

    }

    // @TODO
    public ContactList getContacts() {
        this.l.lock();
        try{
            ContactList res = new ContactList();
            for (Contact c : this.contacts.values()) {
                res.add(c);
            }
            return res;
        }
        finally{
            this.l.unlock();
        }
    }
}
