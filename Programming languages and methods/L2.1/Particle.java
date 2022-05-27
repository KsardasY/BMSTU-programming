public class Particle {
    public double[] coords = new double[3];
    public double m;

    public Particle(double x, double y, double z, double m, Universe universe) {
        this.coords[0] = x;
        this.coords[1] = y;
        this.coords[2] = z;
        this.m = m;
        universe.append(this);
    }
}
