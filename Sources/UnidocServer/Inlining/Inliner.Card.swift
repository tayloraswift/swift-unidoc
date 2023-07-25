import HTML
import UnidocRecords

extension Inliner
{
    struct Card
    {
        let overview:Passage?

        let master:Record.Master
        let target:String?

        init(overview:Passage?, master:Record.Master, target:String?)
        {
            self.overview = overview
            self.master = master
            self.target = target
        }
    }
}
extension Inliner.Card:HyperTextOutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html[self.target == nil ? .span : .a, { $0.href = self.target }]
        {
            switch self.master
            {
            case .article(let master):
                $0 ?= master.stem.last

            case .culture(let master):
                $0 += master.module.id

            case .decl(let master):
                $0 += master.signature.abridged

            case .file(_):
                //  unimplemented
                break
            }
        }

        html ?= self.overview
    }
}
