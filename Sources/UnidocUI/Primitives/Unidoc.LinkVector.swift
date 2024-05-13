

import HTML

extension Unidoc
{
    struct LinkVector
    {
        let context:any VertexContext

        let display:ArraySlice<Substring>
        let scalars:ArraySlice<Scalar>
        let last:LinkReference<DeclVertex>

        private
        init(_ context:any Unidoc.VertexContext,
            display:ArraySlice<Substring>,
            scalars:ArraySlice<Scalar>,
            last:LinkReference<DeclVertex>)
        {
            self.context = context

            self.display = display
            self.scalars = scalars
            self.last = last
        }
    }
}
extension Unidoc.LinkVector
{
    init?(_ context:any Unidoc.VertexContext,
        display:[Substring],
        scalars:[Unidoc.Scalar])
    {
        //  We should never ever have a display path that is shorter than the vector length,
        //  but if somehow we do, we should trim the vector until it fits in the display path.
        let scalars:ArraySlice<Unidoc.Scalar> = scalars.suffix(display.count)
        let display:ArraySlice<Substring> = display.suffix(scalars.count)

        guard
        let last:Int = scalars.indices.last,
        let link:Unidoc.LinkReference<Unidoc.DeclVertex> = context[decl: scalars[last]]
        else
        {
            return nil
        }

        self.init(context, display: display, scalars: scalars[..<last], last: link)
    }
}
extension Unidoc.LinkVector:HTML.OutputStreamable
{
    static
    func += (code:inout HTML.ContentEncoder, self:Self)
    {
        var display:IndexingIterator<ArraySlice<Substring>> = self.display.makeIterator()
        for id:Unidoc.Scalar in self.scalars
        {
            //  This could be a link to something that is not a declaration, such as a module.
            code[.a]
            {
                $0.link = self.context[vertex: id]?.target
            } = display.next()

            code += "."
        }
        if  let last:Substring = display.next()
        {
            code[.a]
            {
                $0.link = self.last.target
            } = last
        }
    }
}
