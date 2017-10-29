MultipartFormData for Swift
===========================

MultipartFormData for Swift.


Basic Usage
-----------

```swift
let result = MultipartFormData.Builder(
        generatingBoundaryBy: RandomBoundaryGenerator()
    )
    .build(with: [
        (
            name: "example1",
            filename: nil,
            mimeType: nil,
            data: "Hello, World!".data(using: .utf8)!
        ),
        (
            name: "example2",
            filename: "example.txt",
            mimeType: MIMEType.textPlain,
            data: "EXAMPLE_TXT".data(using: .utf8)!
        ),
    ])


switch result {
case let .valid(multipartFormData):
    var requrst = URLRequest(url: URL(string: "http://example.com")!)
    request.addValue(multipartFormData.contentType, forHTTPHeaderField: "Content-Type")
    request.httpBody = multipartFormData.body

    let task = URLSession.shared.dataTask(with: request)
    task.resume()

case let .invalid(because: error):
    print(error)
    return
}
```



Advanced Usage
--------------

```swift
let multipartFormData = MultipartFormData(
    uniqueAndValidLengthBoundary: "boundary",
    body: [
        MultipartFormData.Part(
            contentDisposition: ContentDisposition(
                name: Name(asPercentEncoded: "field1"),
                filename: nil
            ),
            contentType: nil,
            content: "value1".data(using: .utf8)!
        ),
        MultipartFormData.Part(
            contentDisposition: ContentDisposition(
                name: Name(asPercentEncoded: "field2"),
                filename: Filename(asPercentEncoded: "example.txt")
            ),
            contentType: ContentType(representing: .textPlain),
            content: "value2".data(using: .utf8)!
        ),
    ]
)

print(multipartFormData.header.name)
// Content-Type

print(multipartFormData.header.value)
// multipart/form-data; boundary="boundary"

switch multipartFormData.asData() {
case let .valid(data):
    print(String(data: data, encoding: .utf8))

    // --boundary
    // Content-Disposition: form-data; name="field1"
    // 
    // value1
    // --boundary
    // Content-Disposition: form-data; name="filed2"; filename="example.txt"
    // Content-Type: text/plain
    // 
    // value2
    // --boundary--

case let .invalid(error):
    print(error)
}
```


License
-------

MIT