enum LocalAddress
{
    case article(Int)
    case culture(Int)
    case scalar(Int32)
}
extension LocalAddress
{
    var article:Int?
    {
        switch self
        {
        case .article(let index):   return index
        case .culture:              return nil
        case .scalar:               return nil
        }
    }
    var culture:Int?
    {
        switch self
        {
        case .article:              return nil
        case .culture(let index):   return index
        case .scalar:               return nil
        }
    }
    var scalar:Int32?
    {
        switch self
        {
        case .article:              return nil
        case .culture:              return nil
        case .scalar(let address):  return address
        }
    }
}
