import Symbols

extension Unidoc
{
    @frozen public
    struct BuildForm
    {
        public
        let symbol:Symbol.PackageAtRef
        public
        let action:Action

        init(symbol:Symbol.PackageAtRef, action:Action)
        {
            self.symbol = symbol
            self.action = action
        }
    }
}
extension Unidoc.BuildForm
{
    static var symbol:String { "symbol" }
    static var action:String { "action" }
}
extension Unidoc.BuildForm
{
    public
    init?(from parameters:borrowing [String: String])
    {
        guard
        let symbol:String = parameters["symbol"],
        let symbol:Symbol.PackageAtRef = .init(symbol),
        let action:String = parameters["action"],
        let action:Action = .init(action)
        else
        {
            return nil
        }

        self.init(symbol: symbol, action: action)
    }
}
