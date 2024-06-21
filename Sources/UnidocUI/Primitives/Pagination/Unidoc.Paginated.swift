import HTML
import URI

extension Unidoc
{
    struct Paginated<Table> where Table:IterableTable, Table:HTML.OutputStreamable
    {
        let table:Table
        let index:Int

        private
        let truncated:Bool

        init(table:Table, index:Int, truncated:Bool)
        {
            self.table = table
            self.index = index
            self.truncated = truncated
        }
    }
}
extension Unidoc.Paginated
{
    var prev:URI? { self.index > 0 ? self.table.more(page: self.index - 1) : nil }
    var next:URI? { self.truncated ? self.table.more(page: self.index + 1) : nil }
}
extension Unidoc.Paginated:HTML.OutputStreamable
{
    static
    func += (section:inout HTML.ContentEncoder, self:Self)
    {
        section[.nav, { $0.class = "paginator" }]
        {
            if  let uri:URI = self.prev
            {
                $0[.a] { $0.href = "\(uri)" } = "prev"
            }
            else
            {
                $0[.span] = "prev"
            }

            if  let uri:URI = self.next
            {
                $0[.a] { $0.href = "\(uri)" } = "next"
            }
            else
            {
                $0[.span] = "next"
            }
        }

        section[.table] = self.table
    }
}
