import HTML

extension Unidoc
{
    @frozen public
    struct PluginError:Error, Sendable
    {
        @usableFromInline
        let type:String
        @usableFromInline
        let path:String?
        @usableFromInline
        let details:String

        @inlinable public
        init(type:String, path:String?, details:String)
        {
            self.type = type
            self.path = path
            self.details = details
        }
    }
}
extension Unidoc.PluginError
{
    init(error:__shared any Error, path:String?)
    {
        self.init(
            type: String.init(reflecting: Swift.type(of: error)),
            path: path,
            details: String.init(reflecting: error))
    }
}
extension Unidoc.PluginError:Unidoc.PluginEvent
{
    @inlinable public
    func h3(_ h3:inout HTML.ContentEncoder)
    {
        h3 += "Server error"
    }

    @inlinable public
    func dl(_ dl:inout HTML.ContentEncoder)
    {
        dl[.dt] = "Type"
        dl[.dd] = self.type

        if  let path:String = self.path
        {
            dl[.dt] = "Path"
            dl[.dd] {$0[.a] { $0.target = "_blank" ; $0.href = path } = path }
        }

        dl[.dt] = "Description"
        dl[.dd, .pre] = self.details
    }
}
