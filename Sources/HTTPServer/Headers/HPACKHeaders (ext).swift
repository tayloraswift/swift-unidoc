import NIOHPACK

extension HPACKHeaders:HTTP.HeaderFormat
{
    init(origin _:HTTP.Origin, status:UInt)
    {
        self = [":status": "\(status)"]
    }

    mutating
    func add(name:String, value:String)
    {
        self.add(name: name, value: value, indexing: .indexable)
    }
}
