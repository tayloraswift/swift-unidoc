protocol CodelinkCollation
{
    static
    func collate(_ path:some BidirectionalCollection<String>) -> String
}
