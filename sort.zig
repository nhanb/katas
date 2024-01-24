const std = @import("std");

pub fn main() void {
    var array = [_]i64{ 12, 1, -1, 4, 100, 40, 3 };
    std.debug.print("{any} <-- before\n", .{array});
    //bubble_sort(&array);
    quicksort(&array);
    std.debug.print("{any} <-- after\n", .{array});
}

fn bubble_sort(slice: []i64) void {
    while (!is_sorted(slice)) {
        for (0..slice.len - 1) |i| {
            if (slice[i] > slice[i + 1]) {
                slice[i] += slice[i + 1];
                slice[i + 1] = slice[i] - slice[i + 1];
                slice[i] -= slice[i + 1];
            }
        }
        std.debug.print("{any}\n", .{slice});
    }
}

fn quicksort(slice: []i64) void {
    std.debug.print("{any}\n", .{slice});
}

fn is_sorted(slice: []i64) bool {
    for (0..slice.len - 1) |i| {
        if (slice[i] > slice[i + 1]) {
            return false;
        }
    }
    return true;
}
