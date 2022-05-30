public class Equation implements Comparable<Equation> {
    public double a;
    public double b;
    public double c;
    public int c_roots;

    public Equation(double a, double b, double c) {
        this.a = a;
        this.b = b;
        this.c = c;
        this.c_roots = root(a, b, c);
    }

    private int root(double a, double b, double c) {
        double discriminant = b * b - 4 * a * c;
        if (discriminant < 0) return 0;
        if (discriminant == 0) return 1;
        return 2;
    }

    public int compareTo(Equation other) {return this.c_roots - other.c_roots;}

    public String toString() { return String.format("(%.1f, %.1f, %.1f)", this.a, this.b, this.c); }
}
