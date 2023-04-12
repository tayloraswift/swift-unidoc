extension Codelink.Path
{
    enum Suffix
    {
        case filter(Codelink.Filter?)
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
    init(_ description:Substring)
    {
        //  https://github.com/apple/swift-docc/blob/main/Sources/SwiftDocC/Utility/FoundationExtensions/String+Hashing.swift
        if let fnv1:UInt32 = .init(description, radix: 36)
        {
            self = .hash(.init(value: fnv1))
            return
        }
        else
        {
            self = .filter(.init(suffix: description))
        }
    }
}
