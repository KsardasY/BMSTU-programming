import java.util.Arrays;

public class Test {
    public static void main(String[] args) {
        GeniusInt[] a = new GeniusInt[] {
                new GeniusInt(1), /* dist == 1(2) */
                new GeniusInt(15), /* dist == 2(13 или 17) */
                new GeniusInt(31), /* dist == 0 */
        };
        Arrays.sort(a);
        for (GeniusInt x : a) System.out.println(x);
    }
}
