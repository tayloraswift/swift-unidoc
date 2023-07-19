extension Optimizer
{
    struct Extensions
    {
        private
        var table:[ExtensionSignature: Extension]

        init(table:[ExtensionSignature: Extension] = [:])
        {
            self.table = table
        }
    }
}
extension Optimizer.Extensions
{
    subscript(signature:Optimizer.ExtensionSignature) -> Optimizer.Extension
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
