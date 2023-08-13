import Unidoc

extension Records
{
    @frozen public
    struct TypeTree:Identifiable
    {
        public
        let id:Unidoc.Scalar
        public
        var top:[Top]

        @inlinable public
        init(id:Unidoc.Scalar, top:[Top] = [])
        {
            self.id = id
            self.top = top
        }
    }
}
extension Records.TypeTree
{
    init(id:Unidoc.Scalar, top nodes:[Records.TypeLevels.Node])
    {
        self.init(id: id)

        for node:Records.TypeLevels.Node in nodes
        {
            var top:Top = .init(stem: node.stem, hash: node.hash)
                top += node.nest

            self.top.append(top)
        }
    }
}
extension Records.TypeTree:CustomStringConvertible
{
    public
    var description:String
    {
        var description:String = ""
        for top:Top in self.top
        {
            description += "\(top.stem)\n"
            for node:Node in top.nest
            {
                description += "\(node.description()) (\(node.stem))\n"
            }
        }
        return description
    }
}
