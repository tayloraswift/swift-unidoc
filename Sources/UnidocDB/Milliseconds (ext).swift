import UnixTime

extension Milliseconds {
    static var minute: Self { .milliseconds(60_000) }

    static var hour: Self { .milliseconds(3_600_000) }

    static var day: Self { .milliseconds(86_400_000) }
}
