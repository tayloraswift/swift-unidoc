extension CommandLine
{
    public
    enum ArgumentError:Error
    {
        case invalid(String, value:String)
        case missing(String)
        case unknown(String)
    }
}
extension CommandLine.ArgumentError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .invalid(let option, value: let value):
            "Invalid value '\(value)' for option '\(option)'"

        case .missing(let option):
            "Expected value for option '\(option)'"

        case .unknown(let option):
            "Unknown option '\(option)'"
        }
    }
}
