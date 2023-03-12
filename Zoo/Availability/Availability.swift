public
enum Availability
{
    @available(*, deprecated)
    case a
    @available(iOS, introduced: 100, message: "introduced message")
    case b
    /// SymbolGraphGen will max “introduced” and min “obsoleted” and
    /// “deprecated”
    @available(swift, introduced: 100.1.2, renamed: "b")
    @available(swift, introduced: 200.1.2, renamed: "b")
    @available(Windows, obsoleted: 200.3, message: "obsoleted message")
    case c
    @available(swift, introduced: 200.1.2, renamed: "b")
    @available(swift, introduced: 100.1.2, renamed: "b")
    case d
    @available(swift, introduced: 200.1.2, renamed: "b")
    @available(swift, obsoleted: 100.1.2, renamed: "z")
    case e
    @available(swift, obsoleted: 200.1.2)
    @available(swift, obsoleted: 300.1.2)
    @available(swift, obsoleted: 100.1.2)
    @available(swift, obsoleted: 200.1.2)
    case f
    @available(iOS, unavailable, message: "unavailable message")
    case g
}
