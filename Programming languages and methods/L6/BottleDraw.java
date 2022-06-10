import javax.swing.*;
import java.awt.*;

public class BottleDraw extends JFrame {
    private int h;
    private int d;
    private int k;

    public BottleDraw(int h, int d, int k) {
        super("2x0.5");
        this.setBounds(0, 0, d + 120, h + 120);
        Container container = this.getContentPane();
        container.add(new BottlePicture(h, d, k));
    }

    public class BottlePicture extends JPanel {
        private int h;
        private int d;
        private int k;

        public BottlePicture(int h, int d, int k) {
            this.h = h;
            this.d = d;
            this.k = k;
            this.setBounds(0, 0, d + 100, h + 100);
            this.setBackground(Color.white);
        }

        public void paint(Graphics g) {
            int cx = (this.d + 100) / 2;
            int fy = this.h + 40;
            int lvl = this.h * this.k / 100;
            g.setColor(Color.blue);
            g.fillRoundRect(cx - this.d / 2, fy - lvl, this.d, lvl, 15, 15);
            g.setColor(Color.black);
            g.drawRoundRect(cx - this.d / 2, fy - this.h, this.d, this.h, 15, 15);
            g.fillRoundRect(cx - 10, fy - this.h - 12, 20, 12, 5, 5);
        }
    }
}
