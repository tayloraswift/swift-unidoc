import UnidocRecords

extension Record.Extension
{
    init(signature:DynamicLinker.ExtensionSignature,
        extension:DynamicLinker.Extension)
    {
        self.init(id: `extension`.id,
            conditions: signature.conditions,
            culture: signature.culture,
            scope: signature.extends,
            conformances: `extension`.conformances,
            features: `extension`.features,
            nested: `extension`.nested,
            subforms: `extension`.subforms)
    }
}
