import Symbols

extension Codelink.Path
{
    enum Suffix
    {
        case filter(SymbolPhylum.Filter)
        case hash(Codelink.Hash)
    }
}
extension Codelink.Path.Suffix
{
    var hash:Codelink.Hash?
    {
        if case .hash(let hash) = self
        {
            return hash
        }
        else
        {
            return nil
        }
    }
}
extension Codelink.Path.Suffix
{
    init?(_ description:String)
    {
        //  https://github.com/apple/swift-docc/blob/main/Sources/SwiftDocC/Utility/FoundationExtensions/String+Hashing.swift
        if let fnv1:UInt32 = .init(description, radix: 36)
        {
            self = .hash(.init(value: fnv1))
            return
        }

        let components:[Substring] = description.split(separator: ".", maxSplits: 1)

        if  components.count == 2,
            components[0] == "swift",
            let filter:SymbolPhylum.Filter = .init(suffix: components[1])
        {
            self = .filter(filter)
        }
        else
        {
            return nil
        }
    }
}
