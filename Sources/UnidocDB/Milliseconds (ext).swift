import Durations

extension Milliseconds
{
    static
    var minute:Self { .seconds(60) }

    static
    var hour:Self { .seconds(3_600) }

    static
    var day:Self { .seconds(86_400) }
}
