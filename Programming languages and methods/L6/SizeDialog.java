import javax.swing.*;
import java.awt.*;
import java.awt.event.*;

public class SizeDialog extends JFrame {
    private JLabel h_label = new JLabel("h");
    private JLabel d_label = new JLabel("d");
    private JLabel k_label = new JLabel("k");
    private JTextField h_field = new JTextField("150", 5);
    private JTextField d_field = new JTextField("60", 5);
    private JTextField k_field = new JTextField("50", 5);
    private JButton next_button = new JButton("Check this out");

    public SizeDialog() {
        super("size dialog");
        this.setBounds(100, 100, 300, 100);
        this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        Container container = this.getContentPane();
        container.setLayout(new GridLayout(3, 2, 2, 2));
        container.add(h_label);
        container.add(d_label);
        container.add(k_label);
        container.add(h_field);
        container.add(d_field);
        container.add(k_field);
        next_button.addActionListener(new Bottle());
        container.add(next_button);
    }

    class Bottle implements ActionListener {
        @Override
        public void actionPerformed(ActionEvent e) {
            int h = Integer.parseInt(h_field.getText());
            int d = Integer.parseInt(d_field.getText());
            int k = Integer.parseInt(k_field.getText());
            BottleDraw bottle = new BottleDraw(h, d, k);
            bottle.setVisible(true);
        }
    }
}
