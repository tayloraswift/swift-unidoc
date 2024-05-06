extension Unidoc.Tooltips
{
    init(filtering vertices:__shared [Unidoc.AnyVertex])
    {
        self.init()
        for vertex:Unidoc.AnyVertex in vertices
        {
            switch vertex
            {
            case .culture(let vertex):  self.cultures.append(vertex)
            case .decl(let vertex):     self.decls.append(vertex)
            default:                    continue
            }
        }
    }
}
