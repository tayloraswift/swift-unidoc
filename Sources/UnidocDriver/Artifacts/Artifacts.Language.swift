extension Artifacts
{
    enum Language
    {
        case c
        case cpp
        case swift
    }
}
extension Artifacts.Language:CustomStringConvertible
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
