import SymbolColonies
import SymbolResolution

extension Compiler
{
    struct Extensions
    {
        private
        var unqualified:[ScalarSymbolResolution: UnqualifiedExtension]
        private
        var qualified:[ExtensionSignature: Extension]
        /// Extensions with symbol names. Each extension may have many
        /// names they can be referred to as.
        private
        var named:[BlockSymbolResolution: Extension]

        init()
        {
            self.unqualified = [:]
            self.qualified = [:]
            self.named = [:]
        }
    }
}
extension Compiler.Extensions
{
    mutating
    func extend(type:ScalarSymbolResolution,
        with symbol:SymbolDescription,
        as block:__owned BlockSymbolResolution) throws
    {
        guard case .extension = symbol.phylum
        else
        {
            throw Compiler.ExtensionPhylumError.init(invalid: symbol.phylum, usr: symbol.usr)
        }

        let object:Compiler.Extension = self[type, where: symbol.extension.conditions]

        if  let block:Compiler.ExtensionBlock = .init(location: symbol.location,
                text: symbol.documentation?.text)
        {
            object.blocks.append(block)
        }

        self.named[block] = object
    }
}

extension Compiler.Extensions
{
    func named(_ block:BlockSymbolResolution) throws -> Compiler.Extension
    {
        if let named:Compiler.Extension = self.named[block]
        {
            return named
        }
        else
        {
            throw Compiler.UndefinedBlockError.init(undefined: block)
        }
    }
}
extension Compiler.Extensions
{
    subscript(type:ScalarSymbolResolution, where _:Never?) -> Compiler.UnqualifiedExtension
    {
        mutating get
        {
            { $0 }(&self.unqualified[type, default: .init(extending: type)])
        }
    }
    subscript(type:ScalarSymbolResolution,
        where conditions:[GenericConstraint<ScalarSymbolResolution>]) -> Compiler.Extension
    {
        mutating get
        {
            let signature:Compiler.ExtensionSignature = .init(type, where: conditions)
            return { $0 }(&self.qualified[signature, default: .init(signature: signature)])
        }
    }
}
