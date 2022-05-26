public class Main {
    public static void main(String[] args) {

        Point PointA = new Point("A");
        System.out.println("Имя точки:"+PointA.getName());
        PointA.setCoord(1.0,1.0,1.0);
        System.out.println("Длинна радиус-вектора:"+PointA.getR());

        //PointA.n=10;
        PointA.val=100;
        System.out.println("ОбъемА:"+Point.val);

        Point PointB = new Point("B");
        System.out.println("ОбъемB:"+Point.val);
    }
}
