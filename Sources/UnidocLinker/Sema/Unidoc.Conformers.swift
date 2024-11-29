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
        where constraints:[GenericConstraint<Unidoc.Scalar>])
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
        with context:Unidoc.LinkerContext) -> Unidoc.ConformerGroup
    {
        .init(id: self.id.in(context.current.id),
            culture: context.current.id + signature.culture,
            scope: signature.conformance,
            unconditional: context.sort(self.unconditional,
                by: Unidoc.LexicalPriority.self),
            conditional: context.sort(self.conditional,
                by: Unidoc.LexicalPriority.self))
    }
}
