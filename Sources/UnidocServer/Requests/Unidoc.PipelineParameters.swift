import FNV1
import MD5
import UnidocRecords

extension Unidoc
{
    struct PipelineParameters
    {
        var explain:Bool
        var beta:Bool
        var hash:FNV24?
        var page:Int?

        let user:Unidoc.Account?
        let tag:MD5?

        private
        init(user:Unidoc.Account?, tag:MD5?)
        {
            self.explain = false
            self.beta = false
            self.hash = nil
            self.page = nil

            self.user = user
            self.tag = tag
        }
    }
}
extension Unidoc.PipelineParameters
{
    init(_ parameters:[(key:String, value:String)]?,
        user:Unidoc.Account? = nil,
        tag:MD5? = nil)
    {
        self.init(user: user, tag: tag)

        guard
        let parameters:[(key:String, value:String)]
        else
        {
            return
        }

        for (key, value):(String, String) in parameters
        {
            switch key
            {
            case "explain": self.explain = value == "true"
            case "beta":    self.beta = value == "true"
            case "hash":    self.hash = .init(value)
            case "page":    self.page = .init(value)
            case _:         continue
            }
        }

        //  As a security measure, clamp the page number to a reasonable range.
        //  This prevents Swift from crashing on integer overflow.
        if  let page:Int = self.page
        {
            self.page = max(0, min(page, 1000))
        }
    }

    static
    var none:Self { .init(user: nil, tag: nil) }
}
