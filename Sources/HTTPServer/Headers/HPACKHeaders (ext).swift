import NIOHPACK

extension HPACKHeaders:HTTPHeaderFormat
{
    init(authority _:(some ServerAuthority).Type, status:UInt)
    {
        self = [":status": "\(status)"]
    }

    mutating
    func add(name:String, value:String)
    {
        self.add(name: name, value: value, indexing: .indexable)
    }
}
