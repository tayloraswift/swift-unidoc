extension Optimizer
{
    struct Extensions
    {
        private
        var table:[DynamicLinker.ExtensionSignature: Extension]

        init(table:[DynamicLinker.ExtensionSignature: Extension] = [:])
        {
            self.table = table
        }
    }
}
extension Optimizer.Extensions
{
    subscript(signature:DynamicLinker.ExtensionSignature) -> Optimizer.Extension
    {
        _read
        {
            yield  self.table[signature, default: .init()]
        }
        _modify
        {
            yield &self.table[signature, default: .init()]
        }
    }
}
