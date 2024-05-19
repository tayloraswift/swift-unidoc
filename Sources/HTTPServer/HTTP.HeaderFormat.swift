extension HTTP
{
    protocol HeaderFormat:Sendable
    {
        init(authority:(some ServerAuthority).Type, status:UInt)

        mutating
        func add(name:String, value:String)
    }
}
