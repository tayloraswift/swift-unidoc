import Signatures

extension GenericOperator
{
    var token:String
    {
        switch self
        {
        case .conformer:    ":"
        case .subclass:     ":"
        case .equal:        "=="
        }
    }
}
