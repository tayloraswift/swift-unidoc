import SemanticVersions
import Symbols

extension Symbol.Package
{
    @inlinable public
    func version(tag:String) -> SemanticVersion?
    {
        switch self
        {
        //  These are the *only* packages that are allowed to use toolchain versions.
        //  SwiftSyntax is not allowed to use them, because it also publishes normal
        //  semver releases.
        case .swift, .swiftPM, .swiftBook, .indexstoreDB:
            guard
            let i:String.Index = tag.firstIndex(of: "-"),
            let j:String.Index = tag.lastIndex(of: "-"),
                j > i,
            let v:NumericVersion = .init(tag[tag.index(after: i) ..< j])
            else
            {
                return nil
            }

            let k:String.Index = tag.index(after: j)

            let version:PatchVersion = .init(padding: v)

            if  case .swiftBook = self
            {
                guard tag[..<i] == "swift"
                else
                {
                    return nil
                }
                if  tag[k...] == "fcs"
                {
                    return .release(version)
                }
                else
                {
                    return .prerelease(version, .init(tag[k...]))
                }
            }
            else if tag[..<i] == "swift", tag[k...] == "RELEASE"
            {
                return .release(version)
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
