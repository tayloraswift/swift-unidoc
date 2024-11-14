extension [(key:String, value:String)]
{
    static func == (a:Self, b:Self) -> Bool
    {
        guard a.count == b.count
        else
        {
            return false
        }

        for (a, b):(Element, Element) in zip(a, b)
        {
            guard a.key == b.key, a.value == b.value
            else
            {
                return false
            }
        }

        return true
    }
}
