extension Double
{
    var percent:String
    {
        let permille:Int = .init((self * 1000).rounded())
        let (percent, f):(Int, Int) = permille.quotientAndRemainder(
            dividingBy: 10)

        return "\(percent).\(f) percent"
    }
}
