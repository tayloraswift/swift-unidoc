import SymbolGraphs
import Symbols

extension DocumentationObject
{
    struct Projector
    {
        let translator:Translator

        private
        let addresses:SymbolTable<ScalarAddress, GlobalAddress?>

        private
        init(translator:Translator, addresses:SymbolTable<ScalarAddress, GlobalAddress?>)
        {
            self.translator = translator
            self.addresses = addresses
        }
    }
}
extension DocumentationObject.Projector
{
    init(translator:DocumentationObject.Translator,
        upstream:__owned [ScalarSymbol: GlobalAddress],
        docs:__shared Documentation)
    {
        self.init(translator: translator,
            addresses: docs.graph.link
            {
                translator[scalar: $0]
            }
            dynamic:
            {
                upstream[$0]
            })
    }
    init(policies:__shared DocumentationDatabase.Policies,
        upstream:__owned [ScalarSymbol: GlobalAddress],
        receipt:__shared DocumentationDatabase.ObjectReceipt,
        docs:__shared Documentation) throws
    {
        self.init(translator: try .init(policies: policies,
                package: receipt.package,
                version: receipt.version,
                docs: docs),
            upstream: upstream,
            docs: docs)
    }
}
extension DocumentationObject.Projector
{
    static
    func * (address:ScalarAddress, self:Self) -> GlobalAddress?
    {
        self.addresses[address] ?? nil
    }
    static
    func / (address:GlobalAddress, self:Self) -> ScalarAddress?
    {
        self.translator[address].scalar
    }
}
