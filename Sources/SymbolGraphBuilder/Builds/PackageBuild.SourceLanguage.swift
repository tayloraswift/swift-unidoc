extension PackageBuild
{
    enum SourceLanguage:Comparable
    {
        case swift
        case c
        case cpp
    }
}
extension PackageBuild.SourceLanguage
{
    static
    func | (lhs:Self, rhs:Self) -> Self
    {
        max(lhs, rhs)
    }
    static
    func |= (lhs:inout Self, rhs:Self)
    {
        lhs = lhs | rhs
    }
}
extension PackageBuild.SourceLanguage:CustomStringConvertible
{
    var description:String
    {
        switch self
        {
        case .c:        return "c"
        case .cpp:      return "c++"
        case .swift:    return "swift"
        }
    }
}
