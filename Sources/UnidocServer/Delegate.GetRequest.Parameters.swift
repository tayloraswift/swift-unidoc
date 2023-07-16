import FNV1
import URI

extension Delegate.GetRequest
{
    struct Parameters:Equatable, Sendable
    {
        var explain:Bool
        var hash:FNV24?

        init()
        {
            self.explain = false
            self.hash = nil
        }
    }
}
extension Delegate.GetRequest.Parameters
{
    init(_ query:URI.Query?)
    {
        self.init()
        for (key, value):(String, String) in query?.parameters ?? []
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
