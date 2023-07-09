extension ModuleSources
{
    enum Language:Comparable
    {
        case swift
        case c
        case cpp
    }
}
extension ModuleSources.Language
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
extension ModuleSources.Language:CustomStringConvertible
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
