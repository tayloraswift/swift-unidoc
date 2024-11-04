import HTML

extension Never:Unidoc.ServerEvent
{
    public
    func h3(_ h3:inout HTML.ContentEncoder) {}

    public
    func dl(_ dl:inout HTML.ContentEncoder) {}
}
