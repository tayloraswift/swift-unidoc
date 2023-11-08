import IP

extension IP
{
    @frozen public
    enum Service:Equatable, Hashable, Sendable
    {
        case amazon
        /// Something running on an EC2 instance. Almost always harmful, but a human
        /// user with a proxy running on AWS might also get this classification.
        case amazonEC2
        case bingbot
        /// Something running on a GCP instance. Almost always harmful, but a human
        /// user with a proxy running on GCP might also get this classification.
        case gcp
        case google
        case googlebot

        /// The IP address could not be mapped to a service because the tables have
        /// not been initialized yet. This is a distinct state from the nil case, because
        /// the IP might still belong to one of the enumerated services.
        case unknown
    }
}
