extension Unidoc
{
    protocol LinkerIndexable:Identifiable<LinkerIndex<Self>>
    {
        associatedtype Signature:Hashable
        associatedtype Assembled

        static
        var type:GroupType { get }

        init(id:LinkerIndex<Self>)

        var isEmpty:Bool { get }

        consuming
        func assemble(signature:Signature, with context:LinkerContext) -> Assembled
    }
}
