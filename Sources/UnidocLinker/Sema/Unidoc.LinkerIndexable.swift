extension Unidoc
{
    typealias LinkerIndexable = _UnidocLinkerIndexable
}
protocol _UnidocLinkerIndexable:Identifiable<Unidoc.LinkerIndex<Self>>
{
    associatedtype Signature:Hashable
    associatedtype Assembled

    static
    var type:Unidoc.GroupType { get }

    init(id:Unidoc.LinkerIndex<Self>)

    var isEmpty:Bool { get }

    consuming
    func assemble(signature:Signature, with linker:borrowing Unidoc.Linker) -> Assembled
}
