import FNV1

extension Swiftinit
{
    struct PipelineParameters
    {
        var explain:Bool
        var hash:FNV24?

        private
        init()
        {
            self.explain = false
            self.hash = nil
        }
    }
}
extension Swiftinit.PipelineParameters
{
    init(_ parameters:[(key:String, value:String)]?)
    {
        self.init()

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
