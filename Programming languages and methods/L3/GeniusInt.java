public class GeniusInt implements Comparable<GeniusInt> {
    public int x;
    public int dist;

    public GeniusInt(int x) {
        this.x = x;
        this.dist = prime_dist(x);
    }

    private Boolean prime(int x) {
        if (x == 1) return false;
        if (x == 2) return true;
        int i = 2;
        while ((i < (int) Math.sqrt(x) + 1 && x % i != 0)) i++;
        if (x % i != 0) return true;
        return false;
    }

    private int prime_dist(int x) {
        if (prime(x)) return 0;
        int i = 1;
        while (!prime(x + i) && !prime(x - i)) i++;
        return i;
    }

    public int compareTo(GeniusInt other) {return this.dist - other.dist;}

    public String toString() {return Integer.toString(this.x);}
}
