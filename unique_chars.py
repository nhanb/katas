# Confirmations
# - ASCII chars or Unicode chars?
# - What if input is empty string?


def has_unique_chars(text) -> bool:
    if not text:
        return True

    seen = set()  # in python it's a hash map
    for char in text:
        if char in seen:  # hash map lookup: O(1) on average
            return False
        seen.add(char)  # hash map insertion: O(1) too

    return True


def has_unique_chars_bit_vector(text) -> bool:
    if not text:
        return True

    # Assuming all ASCII chars, we only need a 128-bit bit vector
    seen = 0
    for char in text:
        position = ord(char)
        if (seen >> position) & 1:  # test bit
            return False
        seen |= 1 << position  # set bit

    return True


cases = (
    ("", True),  # ask for expected result on empty string
    ("123", True),
    ("1231", False),
    ("231  ", False),
)

for func in (
    has_unique_chars,
    has_unique_chars_bit_vector,
):
    for text, expected in cases:
        assert func(text) == expected, (
            f"{func.__name__}({text.__repr__()}) expected {expected}"
        )
print("All tests passed.")
