import java.util.ArrayList;
import java.util.Iterator;
import java.util.Optional;

public class RangeList implements Iterable {
    private ArrayList<Range> list;

    RangeList(ArrayList<Range> list) { this.list = list; }

    public Iterator iterator() { return new RangeIterator(); }

    private class RangeIterator implements Iterator {
        private int i;
        private int j;

        public RangeIterator() {
            i = 0;
            j = 1;
        }

        public boolean hasNext() { return i < list.size() - 1; }

        public Optional<Point> next() {
            int oi = i, oj = j;
            if (j < list.size() - 1) j++;
            else {
                i++;
                j = i + 1;
            }
            return list.get(oi).intersection(list.get(oj));
        }
    }
}
