import UnidocRecords

extension Unidoc
{
    struct Conformers:Identifiable
    {
        let id:LinkerIndex<Self>
        var list:[ConformingType]

        private
        init(id:LinkerIndex<Self>, list:[ConformingType])
        {
            self.id = id
            self.list = list
        }
    }
}
extension Unidoc.Conformers:Unidoc.LinkerIndexable
{
    typealias Signature = Unidoc.ConformanceSignature

    static
    var type:Unidoc.GroupType { .conformers }

    init(id:Unidoc.LinkerIndex<Self>)
    {
        self.init(id: id, list: [])
    }

    var isEmpty:Bool { self.list.isEmpty }

    func assemble(signature:Unidoc.ConformanceSignature,
        with linker:borrowing Unidoc.Linker) -> Unidoc.ConformerGroup
    {
        .init(id: self.id.in(linker.current.id),
            culture: linker.current.id + signature.culture,
            scope: signature.conformance,
            types: self.list) // do we need to sort this?
    }
}
