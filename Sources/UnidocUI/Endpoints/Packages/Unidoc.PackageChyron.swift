import HTML

extension Unidoc
{
    struct PackageChyron
    {
        private
        let source:SourceLink
        private
        let social:SocialMetrics

        init(source:SourceLink, social:SocialMetrics)
        {
            self.source = source
            self.social = social
        }
    }
}
extension Unidoc.PackageChyron:HTML.OutputStreamable
{
    static
    func += (p:inout HTML.ContentEncoder, self:Self)
    {
        p += self.source
        p[.span] = self.social
    }
}
