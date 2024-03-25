import re
from typing import List, NoReturn


def tokenize(filename: str) -> List:
    with open(filename, "r", encoding="UTF8") as f:
        text = "\n" + f.read() + "\n"
    rules = [
        ("COMMENT", r"\n\*.*\n"),
        ("IDENT", r"[a-zA-Z\*]"),
        ("NEWLINE", r"\n"),
        ("SPACE", r"[\t ]"),
        ("ERR", r"."),
    ]
    tokens = list()
    tokens_join = "|".join(f"(?P<{x[0]}>{x[1]})" for x in rules)
    pos = 1
    line = 1
    ex_token_type = "NEWLINE"
    for m in re.finditer(tokens_join, text):
        l, r = m.span()
        token_type = m.lastgroup
        token_lex = m.group(token_type)
        if token_type == "NEWLINE":
            line += 1
            pos = 1
        elif token_type == "SPACE":
            pos += 1
            continue
        elif token_type == "ERR":
            print(f"syntax error ({pos},{line}, {token_lex})")
            pos += r - l
        else:
            tokens.append((token_type, pos, line, token_lex))
            pos += r - l
            if token_type == "COMMENT":
                pos -= 1
    return tokens


def main() -> NoReturn:
    filename = "test1_2.txt"
    tokens = tokenize(filename)
    for t, p, l, val in tokens:
        print(f"{t} ({p},{l}): {val}")


if __name__ == "__main__":
    main()
