import MarkdownSemantics
import UCF

extension SSGC
{
    public
    struct AnchorResolver
    {
        private
        var table:[Int32: [UCF.AnchorMangling: String]]

        public
        init(table:[Int32: [UCF.AnchorMangling: String]] = [:])
        {
            self.table = table
        }
    }
}
extension SSGC.AnchorResolver
{
    mutating
    func index(sections:Markdown.SemanticSections, of id:Int32)
    {
        let anchors:[UCF.AnchorMangling: String] = sections.anchors()
        if  anchors.isEmpty
        {
            return
        }

        self.table[id] = anchors
    }

    subscript(scope:Int32,
        normalizing fragment:String) -> Result<String, SSGC.AnchorResolutionError>
    {
        let id:UCF.AnchorMangling = .init(mangling: fragment)
        guard
        let choices:[UCF.AnchorMangling: String] = self.table[scope]
        else
        {
            return .failure(.init(id: id,
                fragment: fragment,
                scope: scope,
                notes: []))
        }

        guard
        let fragment:String = choices[id]
        else
        {
            var notes:[SSGC.AnchorResolutionError.Note] = choices.map
            {
                .init(id: $0.key, fragment: $0.value)
            }

            notes.sort { $0.id < $1.id }

            return .failure(.init(id: id,
                fragment: fragment,
                scope: scope,
                notes: notes))
        }

        return .success(fragment)
    }
}
