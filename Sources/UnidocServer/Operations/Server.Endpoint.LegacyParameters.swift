import Symbols

extension Server.Endpoint
{
    struct LegacyParameters
    {
        var overload:Symbol.Decl?
        var from:String?

        private
        init()
        {
            self.overload = nil
            self.from = nil
        }
    }
}
extension Server.Endpoint.LegacyParameters
{
    init(_ parameters:[(key:String, value:String)]?)
    {
        self.init()

        guard
        let parameters:[(key:String, value:String)]
        else
        {
            return
        }

        for (key, value):(String, String) in parameters
        {
            switch key
            {
            case "overload":    self.overload = .init(rawValue: value)
            case "from":        self.from = value
            case _:             continue
            }
        }
    }
}
