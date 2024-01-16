import HTML

extension Swiftinit
{
    typealias ServerPluginEvent = _SwiftinitServerPluginEvent
}

protocol _SwiftinitServerPluginEvent:HTML.OutputStreamable, Sendable
{
    static
    var name:String { get }
}
