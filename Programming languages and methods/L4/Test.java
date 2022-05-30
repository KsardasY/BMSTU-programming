import java.util.ArrayList;
import java.util.Optional;

public class Test {
    public static void main(String[] args) {
        ArrayList<Range> b = new ArrayList<>();
        b.add(new Range(new Point(2, 2), new Point(0, 0)));
        b.add(new Range(new Point(2, 4), new Point(2, -2)));
        RangeList a = new RangeList(b);
        for (Object x: a) System.out.println(x);
        b.add(new Range(new Point(0, 1), new Point(1, 0)));
        System.out.println();
        for (Object x: a) System.out.println(x);
    }
}
