import SymbolColonies

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
    func include(extended type:ScalarSymbolResolution,
        with description:SymbolDescription,
        by block:__owned BlockSymbolResolution) throws
    {
        guard case .extension = description.phylum
        else
        {
            throw Compiler.PhylumError.unsupported(description.phylum)
        }

        let object:Compiler.Extension = self[type, where: description.extension.conditions]

        if  let description:Compiler.ExtensionBlock = .init(location: description.location,
                comment: description.documentation?.comment)
        {
            object.blocks.append(description)
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
