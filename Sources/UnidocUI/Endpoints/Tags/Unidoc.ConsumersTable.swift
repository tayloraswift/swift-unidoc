import HTML
import Symbols
import URI

extension Unidoc
{
    struct ConsumersTable
    {
        private
        let dependency:Symbol.Package
        private
        let rows:[PackageDependent]

        init(dependency:Symbol.Package, rows:[PackageDependent])
        {
            self.dependency = dependency
            self.rows = rows
        }
    }
}
extension Unidoc.ConsumersTable:RandomAccessCollection
{
    var startIndex:Int { self.rows.startIndex }
    var endIndex:Int { self.rows.endIndex }

    subscript(index:Int) -> Row { .init(dependent: self.rows[index]) }
}
extension Unidoc.ConsumersTable:Unidoc.IterableTable
{
    func more(page index:Int) -> URI
    {
        Unidoc.ConsumersEndpoint[self.dependency, page: index]
    }
}
extension Unidoc.ConsumersTable:HTML.OutputStreamable
{
    static
    func |= (table:inout HTML.AttributeEncoder, self:Self)
    {
        table[data: "type"] = "consumers"
    }

    static
    func += (table:inout HTML.ContentEncoder, self:Self)
    {
        table[.thead]
        {
            $0[.tr]
            {
                $0[.th] = "Package"
                $0[.th] = "Release"
                $0[.th] = "Docs"
            }
        }

        table[.tbody]
        {
            for row:Row in self
            {
                $0[.tr] = row
            }
        }
    }
}
