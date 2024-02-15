from typing import List, Tuple, NoReturn, Set, Optional, DefaultDict, Dict, Deque
from collections import defaultdict, deque
from treelib import Tree, Node


AUXILIARY_CHARACTERS = {"end": "#", "linefeed": "$", "space": "_"}


class Grammar:
    def __init__(self, filename: str) -> None:
        with open(filename) as f:
            grammar = list(map(str.strip, f.readlines()))
        self.grammar = list(map(lambda x: "".join(x.split()).split("->"), grammar))
        self.augmented_grammar = [(f"{self.grammar[0][0]}'", self.grammar[0][0])]
        for rule in self.grammar:
            if "|" in rule[-1]:
                for alternative in rule[-1].split("|"):
                    self.augmented_grammar.append((rule[0], alternative))
            else:
                self.augmented_grammar.append(tuple(rule))
        self.nonterminals = {rule[0] for rule in self.augmented_grammar}
        self.productions = defaultdict(set)

        def production(nonterminal: str) -> NoReturn:
            for rule in self.augmented_grammar:
                if rule[0] == nonterminal:
                    self.productions[nonterminal].add(rule)
                    if rule[1][0] in self.nonterminals:
                        self.productions[nonterminal] |= self.productions[rule[1][0]]

        def construct_productions() -> NoReturn:
            changed = True
            while changed:
                changed = False
                for nonterminal in self.nonterminals:
                    length = len(self.productions[nonterminal])
                    production(nonterminal)
                    changed += (len(self.productions[nonterminal]) != length)

        construct_productions()
        self.first = defaultdict(set)

        def construct_first() -> NoReturn:
            for char in self.nonterminals:
                for rule in self.productions[char]:
                    if rule[1][0] not in self.nonterminals:
                        self.first[char].add(rule[1][0])

        construct_first()
        self.follow = defaultdict(set)

        def construct_follow() -> NoReturn:
            self.follow[self.augmented_grammar[0][0]].add("#")
            changed = True
            while changed:
                changed = False
                for rule in self.augmented_grammar:
                    char = rule[1][0]
                    for follow_char in rule[1][1:]:
                        if char in self.nonterminals:
                            length = len(self.follow[char])
                            if follow_char in self.nonterminals:
                                self.follow[char] |= self.first[follow_char]
                            else:
                                self.follow[char].add(follow_char)
                            changed += (len(self.follow[char]) != length)
                        char = follow_char
                    if rule[1][-1] in self.nonterminals:
                        length = len(self.follow[rule[1][-1]])
                        self.follow[rule[1][-1]] |= self.follow[rule[0]]
                        changed += (len(self.follow[rule[1][-1]]) != length)

        construct_follow()

    def __str__(self) -> str:
        return "\n".join([" -> ".join(rule) for rule in self.augmented_grammar])

    def get_augmented_rules(self) -> List[Tuple[str, str]]:
        return self.augmented_grammar

    def get_nonteminals(self) -> Set[str]:
        return self.nonterminals

    def get_productions(self) -> DefaultDict[str, Set[Tuple[str, str]]]:
        return self.productions

    def get_first(self) -> DefaultDict[str, Set[Tuple[str, str]]]:
        return self.first

    def get_follow(self) -> DefaultDict[str, Set[Tuple[str, str]]]:
        return self.follow


class LR0Situation:
    def __init__(self, rule: Tuple[str, str], pos: int = 0) -> None:
        self.rule = rule
        self.pos = pos

    def get_ex_observed_char(self) -> str:
        return self.rule[1][self.pos - 1]

    def get_observed_char(self) -> str:
        if self.is_terminal():
            return "#"
        else:
            return self.rule[1][self.pos]

    def get_rule(self) -> Tuple[str, str]:
        return self.rule

    def get_pos(self) -> int:
        return self.pos

    def shift_pos(self, value: int = 1) -> NoReturn:
        self.pos += value

    def is_terminal(self) -> bool:
        return self.pos == len(self.rule[1])

    def __str__(self) -> str:
        return f"{self.rule[0]} -> {self.rule[1][:self.pos]}.{self.rule[1][self.pos:]}"

    def get_next(self) -> 'LR0Situation':
        return LR0Situation(self.rule, self.pos + 1)

    def get_first(self) -> 'LR0Situation':
        return LR0Situation(self.rule, 0)

    def __hash__(self) -> int:
        return hash((self.rule[0], self.rule[1], self.pos))

    def __eq__(self, other: 'LR0Situation') -> bool:
        return (self.pos == other.pos) and (self.rule == other.rule)


class ControlTableCell:
    def __init__(self, value: int = -1,  status: str = "") -> None:
        self.value = value
        self.status = status

    def get_status(self) -> Optional[str]:
        return self.status

    def get_value(self) -> Tuple[LR0Situation] | int:
        return self.value

    def __bool__(self) -> bool:
        return not (self.value == -1 and (not self.status))

    def __str__(self) -> str:
        return f"{self.status}{self.value}"


class PDA:
    def __init__(self, grammar: Grammar) -> None:
        self.start_state = None
        self.terminal_states = set()
        self.states = set()
        self.transition_dict = defaultdict(set)
        self.expanded_states = set()
        self.grammar = grammar
        self.control_table = dict()
        self.numerated_states = dict()
        self.construct_states()
        self.construct_control_table()

    def add_start_state(self) -> NoReturn:
        first_rule = self.grammar.get_augmented_rules()[0]
        self.states.add((LR0Situation(first_rule),))
        self.start_state = (LR0Situation(first_rule),)

    def expand_state(self, state: Tuple[LR0Situation]) -> NoReturn:
        productions = defaultdict(set)
        for lr_0_situation in list(filter(lambda x: not x.is_terminal(), state)):
            observed_char = lr_0_situation.get_observed_char()
            productions[observed_char].add(lr_0_situation)
            for rule in self.grammar.get_productions()[observed_char]:
                prod_lr_0_situation = LR0Situation(rule)
                prod_observed_char = prod_lr_0_situation.get_observed_char()
                productions[prod_observed_char].add(prod_lr_0_situation)
        for char in productions:
            next_state = set()
            is_terminal = False
            for lr_0_situation in productions[char]:
                next_lr_0_situation = lr_0_situation.get_next()
                next_state.add(next_lr_0_situation)
                is_terminal += next_lr_0_situation.is_terminal()
            next_state = tuple(next_state)
            self.states.add(next_state)
            if is_terminal:
                self.terminal_states.add(next_state)
            self.transition_dict[state].add(next_state)
        self.expanded_states.add(state)
        self.numerated_states[state] = len(self.numerated_states)

    def construct_states(self) -> NoReturn:
        self.add_start_state()
        while len(self.expanded_states) != len(self.states):
            for state in self.states - self.expanded_states:
                self.expand_state(state)

    def construct_control_table(self) -> NoReturn:
        for state in self.states:
            for next_state in self.transition_dict[state]:
                char = next_state[0].get_ex_observed_char()
                if not (self.numerated_states[state] in self.control_table):
                    self.control_table[self.numerated_states[state]] = defaultdict(set)
                if char in self.grammar.get_nonteminals():
                    self.control_table[self.numerated_states[state]][char].add(ControlTableCell(
                        value=self.numerated_states[next_state]
                    ))
                else:
                    self.control_table[self.numerated_states[state]][char].add(ControlTableCell(
                        value=self.numerated_states[next_state],
                        status="s"
                    ))
            for lr_0_situation in state:
                if lr_0_situation.is_terminal():
                    for char in self.grammar.get_follow()[lr_0_situation.get_rule()[0]]:
                        if not (self.numerated_states[state] in self.control_table):
                            self.control_table[self.numerated_states[state]] = defaultdict(set)
                        self.control_table[self.numerated_states[state]][char].add(
                            ControlTableCell(
                                value=self.grammar.get_augmented_rules().index(lr_0_situation.get_rule()),
                                status="r"
                            ))

    def get_start_state(self) -> Tuple[LR0Situation]:
        return self.start_state

    def get_states(self) -> Set[LR0Situation]:
        return self.states

    def get_terminal_states(self) -> Set[LR0Situation]:
        return self.terminal_states

    def get_transition_dict(self) -> DefaultDict[LR0Situation, Set[LR0Situation]]:
        return self.transition_dict

    def get_control_table(self) -> Dict[str, DefaultDict[str, Set[ControlTableCell]]]:
        return self.control_table

    def get_index(self, state: Tuple[LR0Situation]) -> int:
        return self.numerated_states[state]

    def get_rule(self, index: int) -> Tuple[str, str]:
        return self.grammar.get_augmented_rules()[index]

    def get_state(self, number: int) -> Tuple[LR0Situation]:
        for x in self.numerated_states:
            if self.numerated_states[x] == number:
                return x

    def is_grammar_lr_0(self) -> bool:
        answer = True
        for lr_0_situations in self.states:
            if any(map(lambda x: x.is_terminal(), lr_0_situations)) and len(lr_0_situations) != 1:
                answer = False
        return answer

    @staticmethod
    def stack_to_str(stack: Deque) -> str:
        i = 0
        res = list()
        while stack:
            char = stack.pop()
            if i:
                res.append(char + second_char)
            else:
                second_char = str(char)
                if len(stack) == 0:
                    res.append(second_char)
            i = (i + 1) % 2
        return " ".join(res[::-1])

    def start_parse(self, word: str) -> Tuple[bool, int, Tree]:
        stack = deque()
        curr_state = 0
        stack.append(0)
        error = False
        accepted = False
        index = 0
        tree = Tree()
        tree.create_node(
            self.stack_to_str(stack.copy()),
            identifier=len(tree),
            parent=None,
            data=0
        )
        result, index = self.parse(word, curr_state, stack, error, accepted, index, tree)
        return result, index, tree

    def parse(
            self,
            word: str,
            curr_state: int,
            stack: deque,
            error: bool,
            accepted: bool,
            index: int,
            tree: Tree,
            parent: int = 0,
            control_cell: Optional[ControlTableCell] = None,
    ) -> Tuple[bool, int]:
        curr_char = word[index]
        while (not accepted) and (not error):
            curr_control_cells = self.control_table[curr_state][curr_char]
            if curr_control_cells:
                if len(curr_control_cells) == 1 or (control_cell is not None):
                    if control_cell is None:
                        curr_control_cell = list(curr_control_cells)[0]
                    else:
                        curr_control_cell = control_cell
                        control_cell = None
                    if curr_control_cell.status != "r":
                        curr_state = curr_control_cell.get_value()
                        stack.append(curr_char)
                        stack.append(curr_state)
                        index += 1
                        curr_char = word[index]
                    else:
                        rule = self.get_rule(curr_control_cell.get_value())
                        for _ in range(len(rule[1]) * 2):
                            stack.pop()
                        if len(rule[0]) == 2:
                            accepted = True
                        else:
                            curr_control_cell = list(self.control_table[stack[-1]][rule[0]])[0]
                            curr_state = curr_control_cell.get_value()
                            stack.append(rule[0])
                            stack.append(curr_state)
                    id = len(tree)
                    tree.create_node(
                        self.stack_to_str(stack.copy()),
                        identifier=id,
                        parent=parent,
                        data=index
                    )
                    parent = id
                else:
                    for curr_control_cell in curr_control_cells:
                        result, idx = self.parse(
                            word,
                            curr_state,
                            stack.copy(),
                            error,
                            accepted,
                            index,
                            tree,
                            parent,
                            curr_control_cell
                        )
                        if result:
                            return result, idx
                    return result, idx
            else:
                error = True
        return accepted, index

    def __len__(self) -> int:
        return len(self.states)

    def __str__(self) -> str:
        states = []
        for state in self.states:
            states.append(str(self.numerated_states[state]) + ": " +
                          ", ".join([str(lr_0_situation) for lr_0_situation in state]))
        states.sort(key=lambda x: int(x.split(":")[0]))
        transitions = list()
        for state in self.transition_dict:
            transitions.append(str(self.numerated_states[state]) + ": " +
                               ", ".join([to[0].get_ex_observed_char() + str(self.numerated_states[to])
                                          for to in self.transition_dict[state]]))
        transitions.sort(key=lambda x: int(x.split(":")[0]))
        return "States:\n" + "\n".join(states) + "\nTransitions:\n" + "\n".join(transitions)


def word_in_grammar(grammar_path: str, word_path: str, step: int) -> Tuple[str, Optional[Tree]]:
    with open(word_path, "r") as f:
        word = list()
        for line in f.readlines():
            line = line.strip()
            word.append(line)
            if line[-1] != "$":
                break
    k = len(word)
    word = "".join(word) + "#"
    if word.count("$") != k - 1:
        return "Слово не принадлежит языку", None
    else:
        grammar = Grammar(grammar_path)
        pda = PDA(grammar)
        print(pda)
        result, index, tree = pda.start_parse(word)
        if step < 0:
            tree = None
        else:
            i = 1
            for node in list(tree.filter_nodes(lambda x: (x.data == step + 1) and
                                                         (tree.parent(x.identifier).data == step))):
                print(i)
                i += 1
                tree.remove_node(node.identifier)
        if result:
            return "Слово принадлежит языку", tree
        return f"Слово не принадлежит языку, позиция: {index}", tree


def main() -> None:
    print("Введите путь к файлу с грамматикой: ")
    grammar_path = input()
    print("Введите путь к файлу со словом: ")
    word_path = input()
    print("Введите шаг, на котором нужно вывести стек: ")
    step = int(input())
    res, tree = word_in_grammar(grammar_path, word_path, step)
    print(res)
    if tree is not None:
        print(tree)


main()
