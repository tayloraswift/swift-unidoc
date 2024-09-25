import FNV1
import URI

extension Unidoc
{
    struct PipelineParameters
    {
        var beta:Bool
        var hash:FNV24?
        var page:Int?

        private
        init()
        {
            self.beta = false
            self.hash = nil
            self.page = nil
        }
    }
}
extension Unidoc.PipelineParameters
{
    init(_ query:URI.Query)
    {
        self.init()

        for (key, value):(String, String) in query.parameters
        {
            switch key
            {
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
    var none:Self { .init() }
}
