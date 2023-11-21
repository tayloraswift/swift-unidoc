import ModuleGraphs
import SemanticVersions

extension PackageIdentifier
{
    @inlinable public
    func version(tag:String) -> SemanticVersion?
    {
        switch self
        {
        //  These are the *only* packages that are allowed to use toolchain versions.
        //  SwiftSyntax is not allowed to use them, because it also publishes normal
        //  semver releases.
        case .swift, .swiftPM:
            guard
            let i:String.Index = tag.firstIndex(of: "-"),
            let j:String.Index = tag.lastIndex(of: "-"),
                j > i,
            let v:NumericVersion = .init(tag[tag.index(after: i) ..< j])
            else
            {
                return nil
            }

            if  tag[..<i] == "swift",
                tag[j...] == "-RELEASE"
            {
                return .release(PatchVersion.init(padding: v))
            }
            else
            {
                return nil
            }

        case _:
            return .init(refname: tag)
        }
    }
}
