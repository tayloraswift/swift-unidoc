import SymbolGraphs
import Unidoc
import UnidocRecords

extension Unidoc.Edition
{
    subscript(id:Unidoc.Linker.Extension.ID) -> Unidoc.Group.ID
    {
        .init(rawValue: self + id.index * .extension)
    }

    subscript(group citizen:Int32) -> Unidoc.Group.ID
    {
        .init(rawValue: self + citizen)
    }
}
