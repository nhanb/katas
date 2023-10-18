"""
Dead simple calculator expression parser & evaluator.
Implemented as a recursive descent parser, which is probably overkill.

Grammar, in order of ascending priority:
    expression -> term
    term -> factor ( ("+" | "-") factor )*
    factor -> NUMBER ( ("*" | "/") NUMBER )*

Also playing around with type hints and type aliases.
"""

from typing import Union

Operator = str
Number = int
Token = Union[Operator, Number]


class BinaryExpr:
    def __init__(self, left, operator, right):
        self.left: Expr = left
        self.operator: Operator = operator
        self.right: Expr = right


Expr = Union[Number, BinaryExpr]

OPERATORS = {"+", "-", "*", "/"}


def lex(expression: str) -> list[Token]:
    tokens = []

    for text in expression.split():
        text = text.strip()
        if text in OPERATORS:
            tokens.append(text)
        else:
            tokens.append(int(text))

    return tokens


def parse(tokens: list[Token]) -> Expr:
    current_index = 0

    def parse_term():
        expr: Expr = parse_factor()
        while operator := match("+", "-"):
            right: Expr = parse_factor()
            expr = BinaryExpr(expr, operator, right)
        return expr

    def parse_factor():
        nonlocal current_index
        expr: Expr = tokens[current_index]
        current_index += 1
        while operator := match("*", "/"):
            right: Expr = tokens[current_index]
            current_index += 1
            expr = BinaryExpr(expr, operator, right)
        return expr

    def match(*matches):
        nonlocal current_index
        if current_index >= len(tokens):
            return None

        if (tok := tokens[current_index]) in matches:
            current_index += 1
            return tok
        return None

    def match_number():
        nonlocal current_index
        tok = tokens[current_index]
        assert isinstance(tok, Number)
        current_index += 1
        return tok

    return parse_term()


def evaluate(expr: Expr) -> int:
    if isinstance(expr, Number):
        return int(expr)

    if expr.operator == "+":
        return evaluate(expr.left) + evaluate(expr.right)

    if expr.operator == "-":
        return evaluate(expr.left) - evaluate(expr.right)

    if expr.operator == "*":
        return evaluate(expr.left) * evaluate(expr.right)

    if expr.operator == "/":
        return evaluate(expr.left) / evaluate(expr.right)

    raise Exception("Invalid expression:", expr)


def calc(input_str):
    tokens = lex(input_str)
    expr = parse(tokens)
    result = evaluate(expr)
    print(input_str, "=", result)
    return result


assert calc("5 + 4 * 3 / 2 - 1") == 10
assert calc("1 * 2 * 3 * 4") == 24
assert calc("1 * 2 * 3 * 4 / 2") == 12
assert calc("1 + 2 * 10") == 21
