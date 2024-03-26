from typing import Optional, NoReturn, List, Union, Dict, Tuple
from lab1_3 import Position, Fragment, Message, Token
from copy import copy


class DFA:
    def __init__(self, n_states: int, final_states: Dict[int, str], transitions: Dict[Tuple[int, str], int]) -> None:
        self.n_states = n_states
        self.final_states = final_states
        self.transitions = transitions
        self.last_final_state = 0
        self.current_state = 0

    def reset(self) -> NoReturn:
        self.current_state = 0
        self.last_final_state = 0

    def exist_transition(self, position: Position) -> bool:
        return (self.current_state, position.get_symbol()) in self.transitions

    def parse(self, position: Position) -> Token:
        self.reset()
        if position.is_end_of_file():
            return Token("END_OF_PROGRAM", copy(position), copy(position))
        value = list()
        start = copy(position)
        end = copy(position)
        while not position.is_end_of_file() and self.exist_transition(position):
            value.append(position.get_symbol())
            if self.current_state in self.final_states:
                self.last_final_state = self.current_state
            self.current_state = self.transitions[(self.current_state, position.get_symbol())]
            end = copy(position)
            position.next()
        if self.current_state in self.final_states:
            return Token(self.final_states[self.current_state], start, end, "".join(value))
        position.next()
        return Token("ERROR", end, end)


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

    def get_scanner(self, filename: str, dfa: DFA) -> 'Scanner':
        with open(filename, "r", encoding="UTF8") as f:
            text = f.readlines()
        text = [string.strip() for string in text]
        text = "\n".join(text)
        return Scanner(text, self, dfa)


class Scanner:
    def __init__(self, program: str, compiler: Compiler, dfa: Optional[DFA] = None) -> None:
        self.cur = Position(program)
        self.compiler = compiler
        self.comments = list()
        self.dfa = dfa

    def get_comments(self) -> List[Fragment]:
        return self.comments

    def get_next_token(self) -> Token:
        while not self.cur.is_end_of_file() and self.cur.is_white_space():
            self.cur.next()
        token = self.dfa.parse(self.cur)
        if token.tag == "IDENT":
            self.compiler.add_name(token.value)
            token.value = self.compiler.get_code(token.value)
        if token.tag == "NUMBER":
            token.value = int(token.value)
        return token

    def tokenize(self) -> NoReturn:
        token = self.get_next_token()
        self.comments.append(token)
        while token.get_tag() != "END_OF_PROGRAM":
            token = self.get_next_token()
            self.comments.append(token)


def create_dfa() -> DFA:
    n_states = 12
    final_states = {
        2: "STRING",
        3: "NUMBER",
        4: "IDENT",
        5: "IDENT",
        6: "IDENT",
        7: "IDENT",
        8: "IDENT",
        9: "SPECIAL",
        10: "SPECIAL",
        11: "SPECIAL"
    }
    transitions = dict()
    for i, c in enumerate("oifd"):
        transitions[(0, c)] = 5 + i
    for i, c in enumerate("dfio"):
        transitions[(5 + i, c)] = 9
    numbers = set([str(i) for i in range(10)])
    letters = set([chr(i) for i in range(ord("a"), ord("z") + 1)] + [chr(i) for i in range(ord("A"), ord("Z") + 1)])
    for i, c in enumerate("dfio"):
        for x in letters - set(c):
            transitions[(5 + i, x)] = 4
    for c in letters - set("dfio"):
        transitions[(0, c)] = 4
    for c in letters | numbers:
        transitions[(4, c)] = 4
    for c in numbers:
        transitions[(0, c)] = 3
    for c in numbers:
        transitions[(3, c)] = 3
    transitions[(0, "`")] = 1
    for i in range(65535):
        c = chr(i)
        if c != '`':
            transitions[(1, "`")] = 1
    for c in letters | numbers:
        transitions[(9, c)] = 4
    transitions[(1, "`")] = 2
    transitions[(0, "{")] = 10
    transitions[(0, "}")] = 11
    return DFA(n_states, final_states, transitions)


def main() -> NoReturn:
    filename = "test1_4.txt"
    compilier = Compiler()
    dfa = create_dfa()
    scanner = compilier.get_scanner(filename, dfa)
    scanner.tokenize()
    for token in scanner.get_comments():
        print(token)


if __name__ == "__main__":
    main()
