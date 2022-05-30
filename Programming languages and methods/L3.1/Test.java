import java.util.Arrays;

public class Test {
    public static void main(String[] args) {
        Equation[] a = new Equation[] {
                new Equation(1, 2, 1), /* -1 */
                new Equation(1, 0, 1), /* Нет корней */
                new Equation(1, -3, 2), /* 1, 2 */
        };
        Arrays.sort(a);
        for (Equation x : a) System.out.println(x);
    }
}
