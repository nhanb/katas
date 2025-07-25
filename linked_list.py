from dataclasses import dataclass
from typing import Optional
from unittest import TestCase

"""
To test:
    python -m unittest linked_list.py
"""


class ListEmpty(Exception):
    pass


class ListIndexNegative(Exception):
    pass


class ListIndexOutOfBounds(Exception):
    pass


# 1. Dead simple LinkedList


@dataclass(slots=True)
class LinkedList:
    @dataclass(slots=True)
    class Node:
        value: object
        next: Optional["LinkedList.Node"] = None

    head: Node | None = None

    def get(self, index):
        if index < 0:
            raise ListIndexNegative()

        if self.head is None:
            raise ListEmpty()

        node = self.head
        currentIndex = 0

        while currentIndex < index:
            if node.next is None:
                raise ListIndexOutOfBounds()
            node = node.next
            currentIndex += 1

        return node.value

    def tail(self):
        if self.head is None:
            return None

        node = self.head
        while node.next is not None:
            node = node.next

        return node.value

    def append(self, value):
        if self.head is None:
            self.head = self.Node(value)
            return

        node = self.head
        while node.next is not None:
            node = node.next

        node.next = self.Node(value)

    # Could be optimized away by maintaining a self.count int attribute
    # and update it upon insertion/deletion.
    def length(self):
        if self.head is None:
            return 0

        length = 1
        node = self.head
        while node.next is not None:
            node = node.next
            length += 1

        return length


class LinkedListTest(TestCase):
    def test_get(self):
        mylist = LinkedList()
        mylist.append("zero")
        mylist.append("one")
        mylist.append("two")
        mylist.append("three")

        self.assertEqual(mylist.get(0), "zero")
        self.assertEqual(mylist.get(1), "one")
        self.assertEqual(mylist.get(2), "two")
        self.assertEqual(mylist.get(3), "three")

        with self.assertRaises(ListIndexOutOfBounds):
            mylist.get(4)

        with self.assertRaises(ListIndexNegative):
            mylist.get(-1)

        with self.assertRaises(ListEmpty):
            empty = LinkedList()
            empty.get(0)

    def test_tail(self):
        mylist = LinkedList()
        self.assertIsNone(mylist.tail())

        mylist.append("one")
        mylist.append("two")
        self.assertEqual(mylist.tail(), "two")

    def test_length(self):
        mylist = LinkedList()
        self.assertEqual(mylist.length(), 0)

        mylist.append("one")
        self.assertEqual(mylist.length(), 1)

        mylist.append("two")
        self.assertEqual(mylist.length(), 2)


# 2. Doubly linked list maybe?
