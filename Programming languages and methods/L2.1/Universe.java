import java.util.ArrayList;

public class Universe {
    public ArrayList<Particle> particles = new ArrayList<>();
    public String name;
    public double m = 0;

    public Universe(String name) {
        this.name = name;
    }

    public void append(Particle particle) {
        this.particles.add(particle);
        this.m += particle.m;
    }

    public int count() {
        return this.particles.size();
    }

    public double[] center_of_gravity() {
        double[] coords = new double[] {0, 0, 0};
        for (int i = 0; i < this.particles.size(); i++) {
            for (int j = 0; j < 3; j++) {
                coords[j] += this.particles.get(i).coords[j] * particles.get(i).m;
            }
        }
        for (int j = 0; j < 3; j++) coords[j] /= this.m;
        return coords;
    }
}
