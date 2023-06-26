extension Diagnostic
{
    @frozen public
    enum Line:Equatable, Sendable
    {
        case annotation(ClosedRange<Int>)
        case source(String)
    }
}
