import HTML

extension Swiftinit
{
    protocol ServerPluginEvent:HTML.OutputStreamable, Sendable
    {
        static
        var name:String { get }
    }
}
