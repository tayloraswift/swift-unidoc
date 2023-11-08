enum PreconditionError:Error
{
    case unreachable
}
extension PreconditionError:CustomStringConvertible
{
    var description:String { "macro failed typechecker validation!" }
}
