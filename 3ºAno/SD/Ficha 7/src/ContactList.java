package src;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;


class ContactList extends ArrayList<Contact> {
    private ArrayList<Contact> listaContactos=new ArrayList<>();
    private Lock l = new ReentrantLock();

    // @TODO
    public ArrayList<Contact> getListaContactos(){
        return  this.listaContactos;
    }
    public void serialize (DataOutputStream out) throws IOException {
            this.l.lock();
            try {
                out.writeInt(this.listaContactos.size());
                for (int i = 0; i < this.listaContactos.size(); i++) {
                    Contact c = this.listaContactos.get(i);
                    out.writeUTF(c.name());
                    out.writeInt(c.age());
                    out.writeLong(c.phoneNumber());
                    if (c.company() != null) {
                        out.writeBoolean(true);
                        out.writeUTF(c.company());
                    }
                    int sizeLista = c.emails().size();
                    out.writeInt(sizeLista);
                    for (String emails : c.emails()) {
                        out.writeUTF(emails);
                    }
                }
            }
            finally {
                this.l.unlock();
            }
    }


    // @TODO
    public static ContactList deserialize (DataInputStream in) throws IOException {
            ContactList res = new ContactList();
            int numeroContactos = in.readInt();
            for (int k = 0; k < numeroContactos; k++) {
                String name = in.readUTF();
                int age = in.readInt();
                long phoneNumber = in.readLong();
                boolean b = in.readBoolean();
                String company = null;
                if (b == true) {
                    company = in.readUTF();
                }
                int sizeLista = in.readInt();
                ArrayList emails = new ArrayList<>(sizeLista);
                for (int i = 0; i < sizeLista; i++) {
                    String email = in.readUTF();
                    emails.add(email);
                }
                Contact cn = new Contact(name, age, phoneNumber, company, emails);
                res.add(cn);
            }
            return res;
    }

}
