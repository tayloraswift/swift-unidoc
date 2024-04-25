import SymbolGraphs
import UCF

extension Codelink
{
    /// The `domain` must share indices with `link`.
    init?(translating link:__shared String, to domain:__shared Substring)
    {
        guard domain.endIndex < link.endIndex
        else
        {
            return nil
        }

        let i:String.Index = link.index(after: domain.endIndex)
        //  Does this look like a link to Swift documentation? If so, we probably already have a
        //  local copy of it.
        switch domain
        {
        case "developer.apple.com":
            //  https://developer.apple.com/documentation/swift/uint16
            let path:[Substring] = link[i...].split(separator: "/")
            if  let c:Int = path.firstIndex(of: "documentation")
            {
                let d:Int = path.index(after: c)
                self.init(
                    base: .qualified,
                    path: .init(components: path[d...].map { $0.lowercased() }))
            }
            else
            {
                return nil
            }

        case "swiftpackageindex.com":
            //  https://swiftpackageindex.com/apple/swift-syntax/509.1.1/documentation/
            let path:[Substring] = link[i...].split(separator: "/")
            if  let c:Int = path.firstIndex(of: "documentation")
            {
                let d:Int = path.index(after: c)
                self.init(
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
