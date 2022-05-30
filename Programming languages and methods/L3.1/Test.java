import java.util.Arrays;

public class Test {
    public static void main(String[] args) {
        Equation[] a = new Equation[] {
                new Equation(1, 2, 1), /* dist == 1(2) */
                new Equation(1, 0, 1), /* dist == 2(13 или 17) */
                new Equation(1, -3, 2), /* dist == 0 */
        };
        Arrays.sort(a);
        for (Equation x : a) System.out.println(x);
    }
}
