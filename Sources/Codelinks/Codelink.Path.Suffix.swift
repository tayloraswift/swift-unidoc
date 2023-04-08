import Symbols

extension Codelink.Path
{
    @frozen public
    enum Suffix
    {
        case fnv(hash:UInt32)
        case phylum(filter:SymbolPhylum.Filter)
    }
}
extension Codelink.Path.Suffix
{
    init?(_ description:String)
    {
        //  https://github.com/apple/swift-docc/blob/main/Sources/SwiftDocC/Utility/FoundationExtensions/String+Hashing.swift
        if let hash:UInt32 = .init(description, radix: 36)
        {
            self = .fnv(hash: hash)
            return
        }

        let components:[Substring] = description.split(separator: ".", maxSplits: 1)

        if  components.count == 2,
            components[0] == "swift",
            let filter:SymbolPhylum.Filter = .init(suffix: components[1])
        {
            self = .phylum(filter: filter)
        }
        else
        {
            return nil
        }
    }
}
