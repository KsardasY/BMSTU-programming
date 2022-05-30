import java.util.Optional;

public class Range {
    Point a;
    Point b;

    public Range(Point a, Point b) {
        this.a = a;
        this.b = b;
    }

    private double[] formulax(Point a, Point b) {
        return new double[] { (b.y - a.y) / (b.x - a.x), - a.x * (b.y - a.y) / (b.x - a.x) + a.y };
    }

    private boolean between(double b, double a, double c) { return (b <= a && a <= c || c <= a && a <= b); }

    public Optional<Point> intersection(Range other) {
        if (this.a.x == this.b.x) {
            if (other.a.x == other.b.x) return Optional.empty();
            if (between(other.a.x, this.a.x, other.b.x)) {
                double[] cf = formulax(other.a, other.b);
                double py = cf[0] * this.a.x + cf[1];
                if (between(this.a.y, py, this.b.y)) return Optional.of(new Point(this.a.x, py));
            } else return Optional.empty();
        }
        if (other.a.x == other.b.x) {
            if (between(this.a.x, other.a.x, this.b.x)) {
                double[] cf = formulax(this.a, this.b);
                double py = cf[0] * other.a.x + cf[1];
                if (between(other.a.y, py, other.b.y)) return Optional.of(new Point(other.a.x, py));
            } else return Optional.empty();
        }
        if (this.a.y == this.b.y && other.a.y == other.b.y) return Optional.empty();
        double[] cf1 = formulax(other.a, other.b), cf2 = formulax(this.a, this.b);
        if (cf1[0] == cf2[0]) return Optional.empty();
        double px = (cf2[1] - cf1[1]) / (cf1[0] - cf2[0]), py = cf1[0] * px + cf1[1];
        if (between(this.a.x, px, this.b.x) && (between(other.a.x, px, other.b.x))) return Optional.of(new Point(px, py));
        return Optional.empty();
    }
}
