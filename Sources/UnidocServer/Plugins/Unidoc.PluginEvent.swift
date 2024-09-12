import HTML

extension Unidoc
{
    public
    protocol PluginEvent:Sendable
    {
        func h3(_ h3:inout HTML.ContentEncoder)
        func dl(_ dl:inout HTML.ContentEncoder)
    }
}
