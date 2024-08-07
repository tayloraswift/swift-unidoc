import FNV1
import Symbols

extension SSGC
{
    @frozen public
    struct Overload:Sendable
    {
        public
        let target:Target
        public
        let hash:FNV24.Extended
        public
        let decl:Phylum.Decl?

        private
        init(target:Target, hash:FNV24.Extended, decl:Phylum.Decl? = nil)
        {
            self.target = target
            self.hash = hash
            self.decl = decl
        }
    }
}
extension SSGC.Overload
{
    static
    func feature(_ decl:SSGC.Decl, self heir:Symbol.Decl) -> Self
    {
        .init(target: .decl(decl.id, self: heir),
            hash: .decl(.init(decl.id, self: heir)),
            decl: decl.phylum)
    }
    static
    func decl(_ decl:SSGC.Decl) -> Self
    {
        .init(target: .decl(decl.id),
            hash: .decl(decl.id),
            decl: decl.phylum)
    }
    static
    func module(_ module:Symbol.Module) -> Self
    {
        .init(target: .module(module), hash: .module(module))
    }
}
