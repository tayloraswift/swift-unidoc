import HTML

extension Unidoc.ConsumersTable
{
    struct Row
    {
        private
        let dependent:Unidoc.PackageDependent

        init(dependent:Unidoc.PackageDependent)
        {
            self.dependent = dependent
        }
    }
}
extension Unidoc.ConsumersTable.Row:HTML.OutputStreamable
{
    static
    func += (tr:inout HTML.ContentEncoder, self:Self)
    {
        tr[.td]
        {
            $0[.a]
            {
                $0.href = "\(Unidoc.RefsEndpoint[self.dependent.package.symbol])"
            } = "\(self.dependent.package.symbol)"
        }

        tr[.td] { $0.class = "ref" } = self.dependent.edition.name

        tr[.td, { $0.class = "version" }]
        {
            guard
            let volume:Unidoc.VolumeMetadata = self.dependent.volume
            else
            {
                return
            }

            $0[.a] { $0.href = "\(Unidoc.DocsEndpoint[volume])" } = volume.symbol.version
        }
    }
}
