import HTML

extension Unidoc
{
    protocol ServerPluginEvent:HTML.OutputStreamable, Sendable
    {
        static
        var name:String { get }
    }
}
