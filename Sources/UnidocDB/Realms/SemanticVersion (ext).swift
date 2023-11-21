import SemanticVersions

extension SemanticVersion
{
    @inlinable public
    init?(swiftRelease string:String)
    {
        guard
        let i:String.Index = string.firstIndex(of: "-"),
        let j:String.Index = string.lastIndex(of: "-"),
            j > i,
        let v:PatchVersion = .init(string[string.index(after: i) ..< j])
        else
        {
            return nil
        }

        if  string[..<i] == "swift",
            string[j...] == "-RELEASE"
        {
            self = .release(v)
        }
        else
        {
            return nil
        }
    }
}
