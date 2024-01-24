// Simplest possible stuff to get me some muscle memory for zig syntax.

const std = @import("std");

pub fn main() void {
    var array = [_]i64{ 12, 1, -1, 4, 100, 40, 3, 2 };
    std.debug.print("{any} <-- before\n", .{array});
    bubble_sort(&array);
    //quicksort(&array);
    std.debug.print("{any} <-- after\n", .{array});
}

fn bubble_sort(slice: []i64) void {
    while (!is_sorted(slice)) {
        for (0..slice.len - 1) |i| {
            if (slice[i] > slice[i + 1]) {
                swap(slice, i, i + 1);
            }
        }
        std.debug.print("{any}\n", .{slice});
    }
}

fn quicksort(slice: []i64) void {
    std.debug.print(">> {any}\n", .{slice});

    switch (slice.len) {
        1 => {},
        2 => if (slice[0] > slice[1]) {
            swap(slice, 0, 1);
        },
        else => {
            var pivot = slice.len / 2;
            var pivot_val = slice[pivot];
            std.debug.print("pivot: {any} ({d})\n", .{ pivot, pivot_val });
            swap(slice, pivot, slice.len - 1);

            //var left: usize = 0;
            //var right: usize = slice.len - 2;
            // TODO

            swap(slice, pivot, slice.len - 1);

            quicksort(slice[0..pivot]);
            quicksort(slice[pivot + 1 ..]);
        },
    }
}

fn is_sorted(slice: []i64) bool {
    for (0..slice.len - 1) |i| {
        if (slice[i] > slice[i + 1]) {
            return false;
        }
    }
    return true;
}

fn swap(slice: []i64, x: usize, y: usize) void {
    slice[x] += slice[y];
    slice[y] = slice[x] - slice[y];
    slice[x] -= slice[y];
}
