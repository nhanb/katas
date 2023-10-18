"""
Dead simple calculator expression parser & evaluator.
Implemented as a recursive descent parser, which is probably overkill.

Grammar, in order of ascending priority:
    expression -> term
    term -> factor ( ("+" | "-") factor )*
    factor -> NUMBER ( ("*" | "/") NUMBER )*

Also playing around with type hints and type aliases: this script passes mypy.
"""

from typing import Optional, Union

Operator = str
Number = int
Token = Union[Operator, Number]


class BinaryExpr:
    def __init__(self, left, operator, right) -> None:
        self.left: Expr = left
        self.operator: Operator = operator
        self.right: Expr = right


Expr = Union[Number, BinaryExpr]

OPERATORS = {"+", "-", "*", "/"}


def lex(expression: str) -> list[Token]:
    tokens: list[Token] = []

    for text in expression.split():
        text = text.strip()
        if text in OPERATORS:
            tokens.append(text)
        else:
            tokens.append(Number(text))

    return tokens


def parse(tokens: list[Token]) -> Expr:
    current_index = 0

    def parse_term() -> Expr:
        expr: Expr = parse_factor()
        while operator := match_operator("+", "-"):
            right: Expr = parse_factor()
            expr = BinaryExpr(expr, operator, right)
        return expr

    def parse_factor() -> Expr:
        nonlocal current_index
        expr: Expr = match_number()
        while operator := match_operator("*", "/"):
            right: Expr = match_number()
            expr = BinaryExpr(expr, operator, right)
        return expr

    def match_operator(*operators: Operator) -> Optional[Token]:
        nonlocal current_index
        if current_index >= len(tokens):
            return None

        if (tok := tokens[current_index]) in operators:
            current_index += 1
            return tok
        return None

    def match_number() -> Number:
        nonlocal current_index
        tok = tokens[current_index]
        assert isinstance(tok, Number)
        current_index += 1
        return tok

    return parse_term()


def evaluate(expr: Expr) -> Number:
    if isinstance(expr, Number):
        return Number(expr)

    if expr.operator == "+":
        return evaluate(expr.left) + evaluate(expr.right)

    if expr.operator == "-":
        return evaluate(expr.left) - evaluate(expr.right)

    if expr.operator == "*":
        return evaluate(expr.left) * evaluate(expr.right)

    if expr.operator == "/":
        return Number(evaluate(expr.left) / evaluate(expr.right))

    raise Exception("Invalid expression:", expr)


def calc(input_str) -> Number:
    tokens = lex(input_str)
    expr = parse(tokens)
    result = evaluate(expr)
    print(input_str, "=", result)
    return result


assert calc("5 + 4 * 3 / 2 - 1") == 10
assert calc("1 * 2 * 3 * 4") == 24
assert calc("1 * 2 * 3 * 4 / 2") == 12
assert calc("1 + 2 * 10") == 21
