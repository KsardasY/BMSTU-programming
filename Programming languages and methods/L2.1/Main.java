import java.util.Arrays;

public class Main {
    public static void main(String[] args) {
        Universe u = new Universe("MilkiWay");
        Particle p1 = new Particle(1, 1, 1, 4, u);
        System.out.println(Arrays.toString(u.center_of_gravity()));
        Particle p2 = new Particle(-1, -1, -1, 12, u);
        System.out.println(Arrays.toString(u.center_of_gravity()));
        System.out.println(u.count());
    }
}