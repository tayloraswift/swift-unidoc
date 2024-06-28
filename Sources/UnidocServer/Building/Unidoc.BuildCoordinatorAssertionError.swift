extension Unidoc
{
    enum BuildCoordinatorAssertionError:Error
    {
        case invalidChangeStreamElement
        case missingClusterTime
        case droppedNotification
        case droppedSubscription
        case overusedSubscription
    }
}
