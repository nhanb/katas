// Simplest possible stuff to get me some muscle memory for zig syntax.

const std = @import("std");
const ArrayList = std.ArrayList;
const eql = std.mem.eql;
const expect = std.testing.expect;
const allocator = std.testing.allocator;
//const allocator = std.heap.page_allocator;

test "bubbleSort" {
    var list = ArrayList(i64).init(allocator);
    defer list.deinit();
    try list.appendSlice(&[_]i64{ 12, 1, -1, 4, 100, 40, 3, 2 });
    bubbleSort(list);
    try expect(eql(i64, list.items, &[_]i64{ -1, 1, 2, 3, 4, 12, 40, 100 }));
}

fn bubbleSort(list: ArrayList(i64)) void {
    while (!isSorted(list)) {
        for (0..list.items.len - 1) |i| {
            if (list.items[i] > list.items[i + 1]) {
                swap(list.items, i, i + 1);
            }
        }
        //std.debug.print("{any}\n", .{list.items});
    }
}

test "quickSort" {
    var list = ArrayList(i64).init(allocator);
    defer list.deinit();
    try list.appendSlice(&[_]i64{ 12, 1, -1, 4, 100, 40, 2, 2 });
    var list2 = try quickSort(list);
    defer list2.deinit();
    try expect(eql(i64, list.items, &[_]i64{ -1, 1, 2, 2, 4, 12, 40, 100 }));
}

fn quickSort(list: ArrayList(i64)) !ArrayList(i64) {
    //std.debug.print(">> {any}\n", .{list.items});

    switch (list.items.len) {
        1 => return list,
        2 => {
            if (list.items[0] > list.items[1]) {
                swap(list.items, 0, 1);
            }
            return list;
        },
        else => {
            var pivot = list.items.len / 2;
            var pivot_val = list.items[pivot];

            var left = ArrayList(i64).init(allocator);
            defer left.deinit();

            var right = ArrayList(i64).init(allocator);
            defer right.deinit();

            for (0.., list.items) |i, item| {
                if (i == pivot) {
                    continue;
                }
                if (item <= pivot_val) {
                    try left.append(item);
                } else {
                    try right.append(item);
                }
            }

            var list_after = ArrayList(i64).init(allocator);

            if (left.items.len > 0) {
                var left_after = try quickSort(left);
                try list_after.appendSlice(left_after.items);
                //left_after.deinit();
            }

            try list_after.append(pivot_val);

            if (right.items.len > 0) {
                var right_after = try quickSort(right);
                try list_after.appendSlice(right_after.items);
                //right_after.deinit();
            }
            return list_after;
        },
    }
}

fn isSorted(list: ArrayList(i64)) bool {
    var slice = list.items;
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
