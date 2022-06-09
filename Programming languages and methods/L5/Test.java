public class Test {
    public static void main(String[] args) {
        FlowByte arr_bytes = new FlowByte();
        arr_bytes.add((byte) 1);
        arr_bytes.add((byte) 2);
        arr_bytes.add((byte) 0);
        arr_bytes.add((byte) -1);
        arr_bytes.add((byte) -2);
        arr_bytes.add((byte) -3);
        arr_bytes.add((byte) 127);
        arr_bytes.add((byte) -128);
        System.out.println(arr_bytes.max_deg());
        arr_bytes.cnn_bytes().forEach(System.out::println);
    }
}
