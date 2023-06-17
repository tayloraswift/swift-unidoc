import ModuleGraphs

struct StandaloneResolver
{
    private
    var items:[Key: Int32]

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
            yield  self.items[.init(namespace: namespace, article: name)]
        }
        _modify
        {
            yield &self.items[.init(namespace: namespace, article: name)]
        }
    }
}
