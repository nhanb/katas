const std = @import("std");
const t = std.testing;
const Thread = std.Thread;

// Thread-safe bounded blocking queue.
// Basically Go's buffered channel without `select`. Targets zig 0.15.2.
// Just an exercise in ring buffers and using mutex & conditions. One can just
// wait for zig 0.16 to get that tricked out Io.Queue thingy.

pub fn Queue(T: anytype, capacity: usize) type {
    return struct {
        /// Backing ring buffer
        buf: [capacity]T = undefined,
        /// Index of the first queued item in the buffer
        head: usize = 0,
        /// Number of items currently in queue
        len: usize = 0,

        // thread safety stuff:
        mut: Thread.Mutex = .{},
        put_cond: Thread.Condition = .{},
        get_cond: Thread.Condition = .{},

        /// If there's no space left, blocks until there is, then insert the item
        pub fn put(self: *@This(), item: T) void {
            self.mut.lock();
            defer self.mut.unlock();

            std.debug.print("putting {any}\n", .{item});

            while (self.len == capacity) {
                self.put_cond.wait(&self.mut);
            }

            const index = (self.head + self.len) % capacity;
            self.buf[index] = item;
            self.len += 1;

            std.debug.print("put {any}\n", .{item});
            self.get_cond.signal();
        }

        /// If there's no space left, immediately returns false
        pub fn putNoWait(self: *@This(), item: T) bool {
            self.mut.lock();
            defer self.mut.unlock();

            if (self.len == capacity) {
                return false;
            }

            const index = (self.head + self.len) % capacity;
            self.buf[index] = item;
            self.len += 1;

            self.get_cond.signal();
            return true;
        }

        /// If queue is empty, blocks until an item has been inserted
        pub fn get(self: *@This()) T {
            self.mut.lock();
            defer self.mut.unlock();

            std.debug.print("getting\n", .{});

            while (self.len == 0) {
                self.get_cond.wait(&self.mut);
            }

            const item = self.buf[self.head];
            self.len -= 1;
            self.head = (self.head + 1) % capacity;

            self.put_cond.signal();
            std.debug.print("got {any}\n", .{item});
            return item;
        }

        /// If queue is empty, immediately returns null
        pub fn getNoWait(self: *@This()) ?T {
            self.mut.lock();
            defer self.mut.unlock();

            if (self.len == 0) {
                return null;
            }

            const item = self.buf[self.head];
            self.len -= 1;
            self.head = (self.head + 1) % capacity;

            self.put_cond.signal();
            return item;
        }
    };
}

fn putItems(q: *Queue(u8, 4)) void {
    const numbers = [_]u8{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    for (numbers) |n| {
        q.put(n);
    }
}

fn getItems(q: *Queue(u8, 4)) void {
    for (0..11) |_| {
        _ = q.get();
    }
}

test Queue {
    var q: Queue(u8, 4) = .{};
    try t.expectEqual(null, q.getNoWait());

    try t.expectEqual(true, q.putNoWait(1));
    try t.expectEqual(true, q.putNoWait(2));
    try t.expectEqual(true, q.putNoWait(3));
    try t.expectEqual(true, q.putNoWait(4));
    try t.expectEqual(false, q.putNoWait(5));

    try t.expectEqual(1, q.getNoWait());
    try t.expectEqual(true, q.putNoWait(99));
    try t.expectEqual(2, q.getNoWait());
    try t.expectEqual(3, q.getNoWait());
    try t.expectEqual(4, q.getNoWait());
    try t.expectEqual(99, q.getNoWait());
    try t.expectEqual(null, q.getNoWait());

    var get_thread = try Thread.spawn(.{}, getItems, .{&q});
    var put_thread = try Thread.spawn(.{}, putItems, .{&q});
    put_thread.join();
    get_thread.join();
}
