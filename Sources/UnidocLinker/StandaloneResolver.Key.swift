import ModuleGraphs

extension StandaloneResolver
{
    struct Key:Equatable, Hashable, Sendable
    {
        private
        let string:String

        private
        init(string:String)
        {
            self.string = string
        }
    }
}
extension StandaloneResolver.Key
{
    init(namespace:__shared ModuleIdentifier, article name:__shared String)
    {
        self.init(string: "\(namespace)/documentation/\(namespace)/\(name.lowercased())")
    }
}
