import java.util.ArrayList;
import java.util.Optional;
import java.util.stream.Stream;


public class FlowByte {
    public ArrayList<Byte> arr = new ArrayList<Byte>();

    public FlowByte() {}

    public void add(byte x) {
        this.arr.add(x);
    }

    private byte not_null_bytes(byte x) {
        byte c = 0;
        if (x < 0) {
            c++;
            x = (byte) (128 + x);
        }
        while (x != 0) {
            if (x % 2 != 0) c++;
            x /= 2;
        }
        return c;
    }

    public Stream<Byte> cnn_bytes() {
        ArrayList<Byte> res = new ArrayList<Byte>();
        this.arr.stream().map(this::not_null_bytes).forEach(res::add);
        return res.stream();
    }

    public Optional<Byte> max_deg() {
        byte md = -1, d, z = 0, t;
        for (byte x : this.arr) {
            if (x > 0) {
                t = x;
                d = 0;
                while (x % 2 == 0) {
                    x /= 2;
                    d++;
                }
                if (x == 1) {
                    md = d;
                    z = t;
                }
            }
        }
        if (md == -1) return Optional.empty();
        return Optional.of(z);
    }
}
