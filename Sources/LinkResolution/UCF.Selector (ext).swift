import FNV1
import UCF

//  TODO: this does not belong in this module
extension UCF.Selector
{
    public
    static func translate(domain:Substring, path:Substring) -> Self?
    {
        //  Does this look like a link to Swift documentation? If so, we probably already have a
        //  local copy of it.
        switch domain
        {
        case "developer.apple.com":
            //  https://developer.apple.com/documentation/swift/uint16
            var path:[Substring] = path.split(separator: "/")
            if  let c:Int = path.firstIndex(of: "documentation")
            {
                let d:Int = path.index(after: c)
                if  let last:Int = path.indices.last
                {
                    {
                        if  let hyphen:String.Index = $0.firstIndex(of: "-"),
                            let _:Int = .init($0[..<hyphen], radix: 10)
                        {
                            //  These numeric prefixes are not FNV-1 hashes, they seem to be
                            //  ordinal numbers generated opaquely by Apple. We can strip them
                            //  in the hopes that the bare path is resolvable, but we can’t use
                            //  them to help disambiguate anything.
                            $0 = $0[$0.index(after: hyphen)...]
                        }
                    } (&path[last])
                }

                return .init(
                    base: .qualified,
                    path: .init(components: path[d...].map { $0.lowercased() }),
                    suffix: nil)
            }
            else
            {
                return nil
            }

        case "swiftpackageindex.com":
            //  https://swiftpackageindex.com/apple/swift-syntax/509.1.1/documentation/
            let path:[Substring] = path.split(separator: "/")
            if  let c:Int = path.firstIndex(of: "documentation")
            {
                let d:Int = path.index(after: c)
                return .init(
                    base: .qualified,
                    path: .init(components: path[d...].map { $0.lowercased() }))
            }
            else
            {
                return nil
            }

        default:
            //  We don't know how to translate other URLs yet.
            return nil
        }
    }
}
