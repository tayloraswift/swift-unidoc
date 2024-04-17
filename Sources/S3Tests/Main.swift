import S3
@_spi(testable)
import S3Client
import Testing

@main
enum Main:TestMain, TestBattery
{
    static
    func run(tests:TestGroup)
    {
        if  let tests:TestGroup = tests / "V4Authorization"
        {
            let credentials:AWS.AccessKey = .init(id: "AKIAIOSFODNN7EXAMPLE",
                secret: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY")
            let computed:String = credentials.sign(put: "Welcome to Amazon S3.",
                storage: .reducedRedundancy,
                bucket: .init(
                    region: .us_east_1,
                    name: "examplebucket"),
                date: .init(weekday: .friday,
                    date: .init(year: 2013, month: .may, day: 24),
                    time: .init(hour: 0, minute: 0, second: 0)),
                path: "/test%24file.text")

            tests.expect(computed ==? """
                AWS4-HMAC-SHA256 \
                Credential=AKIAIOSFODNN7EXAMPLE/20130524/us-east-1/s3/aws4_request,\
                SignedHeaders=date;host;x-amz-content-sha256;x-amz-date;x-amz-storage-class,\
                Signature=5c7844d25514be6e8f67c6199292dea5ed17cd8a5561043b75fbc6bddf745f6b
                """)
        }
    }
}
