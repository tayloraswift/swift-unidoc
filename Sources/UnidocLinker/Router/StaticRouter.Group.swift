extension StaticRouter
{
    enum Group<Element>
    {
        case one  (Element)
        case some([Element])
    }
}
extension StaticRouter.Group:ExpressibleByArrayLiteral
{
    init(arrayLiteral:Element...)
    {
        self = arrayLiteral.count == 1 ? .one(arrayLiteral[0]) : .some(arrayLiteral)
    }
}
extension StaticRouter.Group
{
    mutating
    func append(_ element:__owned Element)
    {
        switch self
        {
        case .one(let first):
            self = .some([first, element])

        case .some(var elements):
            if  elements.isEmpty
            {
                self = .one(element)
            }
            else
            {
                self = .some([])
                elements.append(element)
                self = .some(elements)
            }
        }
    }
}
