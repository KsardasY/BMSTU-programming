import java.util.ArrayList;
import static java.lang.Character.*;

public class Parser {
    public static void main(String[] args) {
        String expression = "a + 10 - (x - 1)";
        show(lex_analyze(expression));
    }
    public enum LexemeType {
        LEFT_BRACKET, RIGHT_BRACKET,
        PLUS, MINUS,
        NUMBER, IDENT,
        NEWLINE
    }

    public static class Lexeme {
        LexemeType type;
        String value;

        public Lexeme(LexemeType type, String value) {
            this.type = type;
            this.value = value;
        }

        public Lexeme(LexemeType type, Character value) {
            this.type = type;
            this.value = value.toString();
        }

        @Override
        public String toString() {
            if (this.type == LexemeType.IDENT || this.type == LexemeType.NUMBER) {
                return this.type.toString();
            }
            return this.value;
        }
    }
    public static ArrayList<Lexeme> lex_analyze(String expression) {
        ArrayList<Lexeme> lexemes = new ArrayList<Lexeme>();
        int pos = 0, row = 1, p = 1;
        while (pos < expression.length()) {
            char c = expression.charAt(pos);
            switch (c) {
                case '(':
                    lexemes.add(new Lexeme(LexemeType.LEFT_BRACKET, c));
                    pos++;
                    p++;
                    continue;
                case ')':
                    lexemes.add(new Lexeme(LexemeType.RIGHT_BRACKET, c));
                    pos++;
                    p++;
                    continue;
                case '+':
                    lexemes.add(new Lexeme(LexemeType.PLUS, c));
                    pos++;
                    p++;
                    continue;
                case '-':
                    lexemes.add(new Lexeme(LexemeType.MINUS, c));
                    pos++;
                    p++;
                    continue;
                default:
                    if (isDigit(c)) {
                        StringBuilder term = new StringBuilder();
                        do {
                            term.append(c);
                            pos++;
                            p++;
                            if (pos >= expression.length()) {
                                break;
                            }
                            c = expression.charAt(pos);
                        } while (isDigit(c));
                        lexemes.add(new Lexeme(LexemeType.NUMBER, term.toString()));
                    } else {
                        if (isLetter(c)) {
                            StringBuilder term = new StringBuilder();
                            do {
                                term.append(c);
                                pos++;
                                p++;
                                if (pos >= expression.length()) {
                                    break;
                                }
                                c = expression.charAt(pos);
                            } while (isLetter(c) || isDigit(c));
                            lexemes.add(new Lexeme(LexemeType.IDENT, term.toString()));
                            pos--;
                            p--;
                        } else {
                            if (c == '\n') {
                                p = 0;
                                row++;
                                lexemes.add(new Lexeme(LexemeType.NEWLINE, '\n'));
                            } else {
                                if (c != ' ') {
                                    throw new RuntimeException(String.format("Syntax error at (%d, %d)", row, p));
                                }
                            }
                        }
                        pos++;
                        p++;
                    }
            }
        }
        return lexemes;
    }

    public static void show(ArrayList<Lexeme> particles) {
        for (int i = 0; i < particles.size(); i++) {
            if (i > 0 && ((particles.get(i - 1).toString().equals("(")) ||
                    (particles.get(i - 1).toString().equals("\n")))
                    || (particles.get(i).toString().equals(")")) || i == 0) {
                System.out.print(particles.get(i));
            } else System.out.print(" " + particles.get(i));
        }
    }
}