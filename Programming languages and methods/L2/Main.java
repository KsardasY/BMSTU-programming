public class Main {
    public static void main(String[] args) {
        Range range1 = new Range(1, 2.5);
        Range range2 = new Range(0.001, 2.3);
        Range range3 = new Range(2.3, 2.4);
        System.out.println(range1.between(2.002));
        System.out.println(range1.entry(range3));
        System.out.println(range2.intersection(range3));
        System.out.println(range1.intersection(range3));
    }
}
