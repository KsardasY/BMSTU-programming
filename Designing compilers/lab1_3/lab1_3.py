from typing import Optional, NoReturn, List, Union
from copy import copy


DOMAIN_TAG = {
    "IDENT": 0,
    "NUMBER": 1,
    "DOUBLE_MINUS": 2,  # --
    "LOWER": 3,  # <
    "LOWER_EQUAL": 4,  # <=
    "ERROR": 5,
    "END_OF_PROGRAM": 6
}


VOWEL = {"a", "e", "i", "o", "u", "y"}


WHITESPACES = {" ", "\t", "\n"}


class Position:
    def __init__(self, text: str) -> None:
        self.text = text
        self.line = 1
        self.pos = 1
        self.index = 0

    def get_line(self) -> int:
        return self.line

    def get_pos(self) -> int:
        return self.pos

    def get_index(self) -> int:
        return self.index

    def __str__(self) -> str:
        return f"({self.line}, {self.pos})"

    def __eq__(self, other: 'Position') -> bool:
        return self.index == other.get_index()

    def __ne__(self, other: 'Position') -> bool:
        return self.index != other.get_index()

    def __lt__(self, other: 'Position') -> bool:
        return self.index < other.get_index()

    def __gt__(self, other: 'Position') -> bool:
        return self.index > other.get_index()

    def __le__(self, other: 'Position') -> bool:
        return self.index <= other.get_index()

    def __ge__(self, other: 'Position') -> bool:
        return self.index >= other.get_index()

    def is_white_space(self) -> bool:
        return self.text[self.index] in WHITESPACES

    def is_letter(self) -> bool:
        return self.text[self.index].isalpha()

    def is_number(self) -> bool:
        return self.text[self.index].isnumeric()

    def is_new_line(self) -> bool:
        return self.text[self.index] == "\n"

    def is_vowel(self) -> bool:
        return self.text[self.index] in VOWEL

    def is_end_of_file(self) -> bool:
        return self.index >= len(self.text)

    def get_symbol(self) -> str:
        return self.text[self.index]

    def next(self) -> NoReturn:
        if not self.is_end_of_file():
            if self.is_new_line():
                self.line += 1
                self.pos = 1
            else:
                self.pos += 1
            self.index += 1


class Fragment:
    def __init__(self, starting: Position, following: Position) -> None:
        self.starting = starting
        self.following = following

    def __str__(self) -> str:
        return f"{str(self.starting)}-{str(self.following)}"


class Message:
    def __init__(self, position: Position, text: str) -> None:
        self.position = position
        self.text = text

    def __str__(self) -> str:
        return f"{str(self.position)}: {self.text}"


class Token:
    def __init__(
            self,
            tag: str,
            start: Position,
            stop: Position,
            value: Optional[Union[str, int]] = None
    ) -> None:
        self.tag = tag
        self.coords = Fragment(start, stop)
        self.value = value

    def get_tag(self) -> str:
        return self.tag

    def __str__(self) -> str:
        return f"{str(self.coords)} {self.tag} {self.value if self.value is not None else ''}"


class Compiler:
    def __init__(self) -> None:
        self.messages = list()
        self.name_codes = dict()
        self.names = list()

    def add_name(self, name: str) -> int:
        if name in self.name_codes:
            return self.name_codes[name]
        code = len(self.name_codes)
        self.names.append(name)
        self.name_codes[name] = code
        return code

    def get_name(self, code: int) -> str:
        return self.names[code]

    def get_code(self, name: str) -> int:
        return self.name_codes[name]

    def add_message(
            self,
            position: Position,
            text: str
    ) -> NoReturn:
        self.messages.append(Message(position, text))

    def get_messages(self) -> List[str]:
        return self.messages

    def get_scanner(self, filename: str) -> 'Scanner':
        with open(filename, "r", encoding="UTF8") as f:
            text = f.readlines()
        text = [string.strip() for string in text]
        text = "\n".join(text)
        return Scanner(text, self)


class Scanner:
    def __init__(self, program: str, compiler: Compiler) -> None:
        self.cur = Position(program)
        self.compiler = compiler
        self.comments = list()

    def get_comments(self) -> List[Fragment]:
        return self.comments

    def get_next_token(self) -> Token:
        value = list()
        while not self.cur.is_end_of_file() and self.cur.is_white_space():
            self.cur.next()
        if self.cur.is_end_of_file():
            return Token("END_OF_PROGRAM", self.cur, self.cur)
        elif self.cur.is_vowel():
            value.append(self.cur.get_symbol())
            start = copy(self.cur)
            end = copy(self.cur)
            while not self.cur.is_end_of_file() and self.cur.is_letter():
                value.append(self.cur.get_symbol())
                end = copy(self.cur)
                self.cur.next()
            value = "".join(value)
            self.compiler.add_name(value)
            return Token("IDENT", start, end, self.compiler.get_code(value))
        elif self.cur.get_symbol() == "-":
            value.append("-")
            start = copy(self.cur)
            self.cur.next()
            if self.cur.get_symbol() == "-":
                end = copy(self.cur)
                self.cur.next()
                return Token("OPERATION", start, end, "--")
            elif self.cur.is_number():
                while not self.cur.is_end_of_file() and self.cur.is_number():
                    value.append(self.cur.get_symbol())
                    end = copy(self.cur)
                    self.cur.next()
                return Token("NUMBER", start, end, int("".join(value)))
            start = copy(self.cur)
            self.cur.next()
            return Token("ERROR", start, start, f"Expected '-' or number, found '{start.get_symbol()}'")
        elif self.cur.get_symbol() == "<":
            start = copy(self.cur)
            self.cur.next()
            if self.cur.get_symbol() == "=":
                end = copy(self.cur)
                self.cur.next()
                return Token("LOWER_EQUAL", start, end)
            return Token("LOWER", start, start)
        elif self.cur.is_number():
            start = copy(self.cur)
            while not self.cur.is_end_of_file() and self.cur.is_number():
                value.append(self.cur.get_symbol())
                end = copy(self.cur)
                self.cur.next()
            return Token("NUMBER", start, end, int("".join(value)))
        start = copy(self.cur)
        self.cur.next()
        return Token("ERROR", start, start, f"The symbol '{start.get_symbol()}' can't be the beginning of a token")

    def tokenize(self) -> NoReturn:
        token = self.get_next_token()
        self.comments.append(token)
        while token.get_tag() != "END_OF_PROGRAM":
            token = self.get_next_token()
            self.comments.append(token)


def main() -> NoReturn:
    filename = "test1_3.txt"
    compilier = Compiler()
    scanner = compilier.get_scanner(filename)
    scanner.tokenize()
    for token in scanner.get_comments():
        print(str(token))


if __name__ == "__main__":
    main()
