extension StaticDiagnostic
{
    enum Line
    {
        case annotation(ClosedRange<Int>)
        case source(String)
    }
}
