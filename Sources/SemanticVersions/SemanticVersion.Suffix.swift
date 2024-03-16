extension SemanticVersion
{
    @frozen public
    enum Suffix:Equatable, Hashable, Sendable
    {
        case release(build:String? = nil)
        case prerelease(String, build:String? = nil)
    }
}
