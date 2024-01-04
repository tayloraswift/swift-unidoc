import SymbolGraphs
import Unidoc
import UnidocRecords

extension Unidoc.Edition
{
    subscript(id:Unidoc.Linker.Extension.ID) -> Unidoc.Group.ID
    {
        .init(rawValue: self + id.index * .extension)
    }
    @inlinable public
    subscript(polygon i:Int) -> Unidoc.Group.ID
    {
        .init(rawValue: self + i * .autogroup)
    }
    @inlinable public
    subscript(topic i:Int) -> Unidoc.Group.ID
    {
        .init(rawValue: self + i * .topic)
    }
}
