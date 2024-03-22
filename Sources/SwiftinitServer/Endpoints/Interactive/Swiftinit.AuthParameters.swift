extension Swiftinit
{
    struct AuthParameters
    {
        /// Only used for testing, never sent by GitHub.
        var token:String?
        /// Defined and sent by GitHub.
        var state:String?
        /// Defined and sent by GitHub.
        var code:String?
        /// Defined by us and parroted back by GitHub.
        var from:String?

        private
        init()
        {
            self.token = nil
            self.state = nil
            self.code = nil
            self.from = nil
        }
    }
}
extension Swiftinit.AuthParameters
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
            case "token":   self.token = value
            case "state":   self.state = value
            case "code":    self.code = value
            case "from":    self.from = value
            case _:         continue
            }
        }
    }
}
