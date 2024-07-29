import FNV1
import SymbolGraphs
import UCF

extension UCF.Selector
{
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
                let suffix:Suffix?

                if  let last:Int = path.indices.last
                {
                    suffix =
                    {
                        if  let hyphen:String.Index = $0.firstIndex(of: "-"),
                            let hash:FNV24 = .init($0[..<hyphen], radix: 10)
                        {
                            $0 = $0[$0.index(after: hyphen)...]
                            return .hash(hash)
                        }
                        else
                        {
                            return nil
                        }
                    } (&path[last])
                }
                else
                {
                    suffix = nil
                }

                return .init(
                    base: .qualified,
                    path: .init(components: path[d...].map { $0.lowercased() }),
                    suffix: suffix)
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
