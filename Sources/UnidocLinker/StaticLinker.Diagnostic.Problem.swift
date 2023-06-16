import CodelinkResolution

extension StaticLinker.Diagnostic
{
    enum Problem
    {
        case ambiguousCodelink(String, [Overload<Int32>])
        case invalidCodelink(String)
    }
}
