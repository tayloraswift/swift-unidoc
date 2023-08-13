import Unidoc

extension Records
{
    struct TypeLevels
    {
        private
        var nested:[[Unidoc.Scalar: (Unidoc.Scalar?, node:Node)]]
        private(set)
        var top:[Unidoc.Scalar: Node]

        init()
        {
            self.nested = []
            self.top = [:]
        }
    }
}
extension Records.TypeLevels
{
    subscript(depth:Int, id:Unidoc.Scalar) -> (Unidoc.Scalar?, node:Node)?
    {
        get
        {
            let i:Int = depth - 2

            if  i < self.nested.startIndex
            {
                return self.top[id].map { (nil, $0) }
            }
            else if
                i < self.nested.endIndex
            {
                return self.nested[i][id]
            }
            else
            {
                return nil
            }
        }
        set(value)
        {
            let i:Int = depth - 2

            if  i < self.nested.startIndex
            {
                self.top[id] = value?.node
            }
            else if
                i < self.nested.endIndex
            {
                self.nested[i][id] = value
            }
            else if let value
            {
                for _:Int in self.nested.endIndex ..< i
                {
                    self.nested.append([:])
                }

                self.nested.append([id: value])
            }
        }
    }

    mutating
    func collapse()
    {
        while   var deepest:[Unidoc.Scalar: (Unidoc.Scalar?, Node)] =
                    self.nested.popLast()
        {
            let above:Int? = self.nested.indices.last

            var i:Dictionary<Unidoc.Scalar, (Unidoc.Scalar?, Node)>.Index =
                deepest.startIndex

            while   i < deepest.endIndex
            {
                defer
                {
                    i = deepest.index(after: i)
                }

                deepest.values[i].1.sort()

                let (id):Unidoc.Scalar
                let (scope, node):(Unidoc.Scalar?, Node)

                (id, (scope, node)) = deepest[i]

                if  let above,
                    let scope,
                    let _:Void = self.nested[above][scope]?.node.nest.append(node)
                {
                }
                else if
                    let scope,
                    let _:Void = self.top[scope]?.nest.append(node)
                {
                }
                else
                {
                    self.top[id] = node
                }
            }
        }
    }
}
