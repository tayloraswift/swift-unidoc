public
protocol DollhouseKeychain:RandomAccessCollection
{
    associatedtype Dollhouse
}
extension DollhouseKeychain
{
    public
    func find(for _:Dollhouse) -> Element?
    {
        nil
    }
}
