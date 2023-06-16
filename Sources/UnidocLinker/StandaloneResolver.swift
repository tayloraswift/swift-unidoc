import ModuleGraphs

struct StandaloneResolver
{
    private
    var items:[String: Int32]

    init()
    {
        self.items = [:]
    }
}
extension StandaloneResolver
{
    //  Note: namespace is case-sensitive, but name is not.
    subscript(namespace:ModuleIdentifier, name:String) -> Int32?
    {
        _read
        {
            yield  self.items["\(namespace)/\(name.lowercased())"]
        }
        _modify
        {
            yield &self.items["\(namespace)/\(name.lowercased())"]
        }
    }
}
