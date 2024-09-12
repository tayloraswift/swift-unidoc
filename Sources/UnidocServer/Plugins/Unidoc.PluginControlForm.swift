import URI

extension Unidoc
{
    struct PluginControlForm
    {
        let active:Bool

        init(active:Bool)
        {
            self.active = active
        }
    }
}
extension Unidoc.PluginControlForm:URI.QueryDecodable
{
    static var active:String { "active" }

    init?(parameters:borrowing [String: String])
    {
        guard
        let active:String = parameters[Self.active],
        let active:Bool = .init(active)
        else
        {
            return nil
        }

        self.init(active: active)
    }
}
