import Signatures
import UnidocRecords

extension Unidoc
{
    struct Conformers:Identifiable
    {
        let id:LinkerIndex<Self>

        private
        var unconditional:[Unidoc.Scalar]
        private
        var conditional:[ConformingType]

        init(id:LinkerIndex<Self>)
        {
            self.id = id
            self.unconditional = []
            self.conditional = []
        }
    }
}
extension Unidoc.Conformers
{
    mutating
    func append(conformer type:Unidoc.Scalar,
        where constraints:[GenericConstraint<Unidoc.Scalar?>])
    {
        constraints.isEmpty
            ? self.unconditional.append(type)
            : self.conditional.append(.init(id: type, where: constraints))
    }
}
extension Unidoc.Conformers:Unidoc.LinkerIndexable
{
    typealias Signature = Unidoc.ConformanceSignature

    static
    var type:Unidoc.GroupType { .conformer }

    var isEmpty:Bool
    {
        self.unconditional.isEmpty && self.conditional.isEmpty
    }

    consuming
    func assemble(signature:Unidoc.ConformanceSignature,
        with linker:borrowing Unidoc.Linker) -> Unidoc.ConformerGroup
    {
        .init(id: self.id.in(linker.current.id),
            culture: linker.current.id + signature.culture,
            scope: signature.conformance,
            unconditional: linker.sort(self.unconditional,
                by: Unidoc.LexicalPriority.self),
            conditional: linker.sort(self.conditional,
                by: Unidoc.LexicalPriority.self))
    }
}
