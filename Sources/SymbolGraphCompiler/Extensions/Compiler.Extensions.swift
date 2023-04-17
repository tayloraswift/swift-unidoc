import SymbolDescriptions

extension Compiler
{
    public
    struct Extensions
    {
        private
        var groups:[Extension.Signature: ExtensionReference]
        /// Extensions with symbol names. Each extension may have many
        /// names they can be referred to as.
        private
        var named:[BlockSymbolResolution: ExtensionReference]

        init()
        {
            self.groups = [:]
            self.named = [:]
        }
    }
}
extension Compiler.Extensions
{
    public
    func load() -> [Compiler.Extension]
    {
        self.groups.values.map(\.value).sorted { $0.signature < $1.signature }
    }
}
extension Compiler.Extensions
{
    mutating
    func include(block:__owned BlockSymbolResolution,
        extending type:ScalarSymbolResolution,
        with description:SymbolDescription,
        in context:Compiler.Context) throws
    {
        guard case .extension = description.phylum
        else
        {
            throw Compiler.PhylumError.unsupported(description.phylum)
        }

        let group:Compiler.ExtensionReference =
            self[type, where: description.extension.conditions]
        
        if  let block:Compiler.Extension.Block = .init(
                location: description.location.flatMap(context.resolve(location:)),
                comment: description.documentation.flatMap(context.filter(documentation:)))
        {
            group.append(block: block)
        }

        self.named[block] = group
    }
}

extension Compiler.Extensions
{
    func named(_ block:BlockSymbolResolution) throws -> Compiler.ExtensionReference
    {
        if let named:Compiler.ExtensionReference = self.named[block]
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
    subscript(extended:ScalarSymbolResolution,
        where conditions:[GenericConstraint<ScalarSymbolResolution>]?)
        -> Compiler.ExtensionReference
    {
        mutating get
        {
            let signature:Compiler.Extension.Signature = .init(extended, where: conditions)
            return { $0 }(&self.groups[signature, default: .init(value: .init(
                signature: signature))])
        }
    }
}
