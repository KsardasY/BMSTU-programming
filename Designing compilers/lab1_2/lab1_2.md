% Лабораторная работа № 1.2. «Лексический анализатор
  на основе регулярных выражений»
% 4 марта 2024 г.
% Андрей Мельников, ИУ9-62Б

# Цель работы
Целью данной работы является приобретение навыка разработки простейших лексических анализаторов, работающих
на основе поиска в тексте по образцу, заданному регулярным выражением.

# Индивидуальный вариант
* Комментарии: целиком строка текста, начинающаяся с «*».
* Идентификаторы: либо последовательности латинских букв нечётной длины, либо последовательности символов «*».
* Ключевые слова: «with», «end», «**».

# Реализация

```python
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
```

# Тестирование

Входные данные

```
sfqefq{
**esfqffseefs}}{

ident **** with end ** ab***abc*
```

Вывод на `stdout`

```
syntax error (7,2, {)
IDENT (1,2): s
IDENT (2,2): f
IDENT (3,2): q
IDENT (4,2): e
IDENT (5,2): f
IDENT (6,2): q
COMMENT (8,2): 
**esfqffseefs}}{

IDENT (1,3): i
IDENT (2,3): d
IDENT (3,3): e
IDENT (4,3): n
IDENT (5,3): t
IDENT (7,3): *
IDENT (8,3): *
IDENT (9,3): *
IDENT (10,3): *
IDENT (12,3): w
IDENT (13,3): i
IDENT (14,3): t
IDENT (15,3): h
IDENT (17,3): e
IDENT (18,3): n
IDENT (19,3): d
IDENT (21,3): *
IDENT (22,3): *
IDENT (24,3): a
IDENT (25,3): b
IDENT (26,3): *
IDENT (27,3): *
IDENT (28,3): *
IDENT (29,3): a
IDENT (30,3): b
IDENT (31,3): c
IDENT (32,3): *
```

# Вывод
В ходе выполнения данной лаборторной работы, были получены навыки разработки простейших лексических 
анализаторов, работающих на основе поиска в тексте по образцу, заданному регулярным выражением, а также
реализован лексический анализатор для языка из индивидуального варианта.
