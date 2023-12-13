import FNV1
import MD5
import UnidocRecords

extension Swiftinit
{
    struct PipelineParameters
    {
        var explain:Bool
        var hash:FNV24?

        let user:Unidex.User.ID?
        let tag:MD5?

        private
        init(user:Unidex.User.ID?, tag:MD5?)
        {
            self.explain = false
            self.hash = nil

            self.user = user
            self.tag = tag
        }
    }
}
extension Swiftinit.PipelineParameters
{
    init(_ parameters:[(key:String, value:String)]?,
        user:Unidex.User.ID? = nil,
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
            case "hash":    self.hash = .init(value)
            case _:         continue
            }
        }
    }
}
