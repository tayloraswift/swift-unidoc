import Symbols
import UCF

extension UCF.CausalOverload
{
    static
    func feature(_ decl:SSGC.Decl, self heir:Symbol.Decl) -> Self
    {
        .init(phylum: decl.phylum,
            decl: decl.id,
            heir: heir,
            hash: .decl(.init(decl.id, self: heir)))
    }
    static
    func decl(_ decl:SSGC.Decl) -> Self
    {
        .init(phylum: decl.phylum,
            decl: decl.id,
            heir: nil,
            hash: .decl(decl.id))
    }
}
