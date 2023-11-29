package src;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.util.*;


class Contact {
    private String name;
    private int age;
    private long phoneNumber;
    private String company;     // Pode ser null
    private ArrayList<String> emails;

    public Contact (String name, int age, long phoneNumber, String company, List<String> emails) {
        this.name = name;
        this.age = age;
        this.phoneNumber = phoneNumber;
        this.company = company;
        this.emails = new ArrayList<>(emails);
    }

    public String name() { return name; }
    public int age() { return age; }
    public long phoneNumber() { return phoneNumber; }
    public String company() { return company; }
    public List<String> emails() { return new ArrayList(emails); }

    // @TODO
    public void serialize (DataOutputStream out) throws IOException {
        out.writeUTF(this.name);
        out.writeInt(this.age);
        out.writeLong(this.phoneNumber);
        if (this.company!=null){
            out.writeBoolean(true);
            out.writeUTF(this.company);
        }
        int sizeLista=this.emails.size();
        out.writeInt(sizeLista);
        for(String emails:this.emails){
            out.writeUTF(emails);
        }

    }

    // @TODO
    public static Contact deserialize (DataInputStream in) throws IOException {
        String name=in.readUTF();
        int age=in.readInt();
        long phoneNumber=in.readLong();
        boolean b=in.readBoolean();
        String company=null;
        if (b==true){
            company=in.readUTF();
        }
        int sizeLista=in.readInt();
        ArrayList emails= new ArrayList<>(sizeLista);
        for (int i=0;i<sizeLista;i++){
            String email=in.readUTF();
            emails.add(email);
        }

        return  new Contact(name,age,phoneNumber,company,emails);
    }

    public String toString () {
        StringBuilder builder = new StringBuilder();
        builder.append(this.name).append(";");
        builder.append(this.age).append(";");
        builder.append(this.phoneNumber).append(";");
        builder.append(this.company).append(";");
        builder.append(this.emails.toString());
        builder.append("}");
        return builder.toString();
    }

}
