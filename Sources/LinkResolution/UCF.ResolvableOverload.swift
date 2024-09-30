import FNV1
import Symbols
import UCF

extension UCF
{
    public
    protocol ResolvableOverload:Identifiable<Symbol.Decl>, Sendable
    {
        var phylum:Phylum.Decl { get }
        var hash:FNV24 { get }

        var documented:Bool { get }
    }
}
extension UCF.ResolvableOverload
{
    static func ~= (suffix:UCF.Selector.Suffix, self:Self) -> Bool
    {
        switch suffix
        {
        case .legacy(let filter, nil):  filter ~= self.phylum
        case .legacy(_, let hash?):     hash == self.hash
        case .hash(let hash):           hash == self.hash
        case .filter(let filter):       filter ~= self.phylum
        }
    }
}
