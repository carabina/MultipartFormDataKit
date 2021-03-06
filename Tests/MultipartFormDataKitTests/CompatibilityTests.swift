import Foundation
import XCTest
import MultipartFormDataKit


class CompatibilityTests: XCTestCase {
    // You can test compatibility by communicating to the actual server by
    // disabling this skip flag. If you have no any server that can take
    // multipart/form-data, you can use `Assets/CompatibilityTests/Server/index.js`.
    // This server can start by the following command:
    //
    //   $ cd Assets/CompatibilityTests/Server/index.js
    //   $ npm install
    //   $ node index.js
    //   Listening on http://localhost:8080
    //
    let skip = true
    let serverURLString = "http://localhost:8080/echo"


    func testEmpty() {
        guard !self.skip else { return }

        let builder = MultipartFormData.Builder(
            generatingBoundaryBy: RandomBoundaryGenerator()
        )

        switch builder.build(with: []) {
        case let .valid(multipartFormData):
            var request = URLRequest(url: URL(string: self.serverURLString)!)

            request.httpMethod = "POST"
            request.addValue(multipartFormData.contentType, forHTTPHeaderField: "Content-Type")
            request.httpBody = multipartFormData.body

            self.assertSuccessfulResponse(request: request)

        case let .invalid(because: error):
            print("\(error)")
        }
    }


    func testSingle() {
        guard !self.skip else { return }

        let builder = MultipartFormData.Builder(
            generatingBoundaryBy: RandomBoundaryGenerator()
        )

        switch builder.build(with: [
            (
                name: "example",
                filename: "example.txt",
                mimeType: MIMEType.textPlain,
                data: "EXAMPLE_TXT".data(using: .utf8)!
            ),
        ]) {
        case let .valid(multipartFormData):
            var request = URLRequest(url: URL(string: self.serverURLString)!)

            request.httpMethod = "POST"
            request.addValue(multipartFormData.contentType, forHTTPHeaderField: "Content-Type")
            request.httpBody = multipartFormData.body

            self.assertSuccessfulResponse(request: request)

        case let .invalid(because: error):
            print("\(error)")
        }
    }


    func testDouble() {
        guard !self.skip else { return }

        let builder = MultipartFormData.Builder(
            generatingBoundaryBy: RandomBoundaryGenerator()
        )

        switch builder.build(with: [
            (
                name: "text",
                filename: nil,
                mimeType: nil,
                data: "EXAMPLE_TXT".data(using: .utf8)!
            ),
            (
                name: "example",
                filename: "example.txt",
                mimeType: MIMEType.textPlain,
                data: "EXAMPLE_TXT".data(using: .utf8)!
            ),
        ]) {
        case let .valid(multipartFormData):
            var request = URLRequest(url: URL(string: self.serverURLString)!)

            request.httpMethod = "POST"
            request.addValue(multipartFormData.contentType, forHTTPHeaderField: "Content-Type")
            request.httpBody = multipartFormData.body

            self.assertSuccessfulResponse(request: request)

        case let .invalid(because: error):
            print("\(error)")
        }
    }



    func assertSuccessfulResponse(request: URLRequest) {
        let expectation = self.expectation(description: "awaiting \(self.serverURLString)")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse else {
                XCTFail(error.debugDescription)
                expectation.fulfill()
                return
            }

            XCTAssertEqual(response.statusCode, 200)

            print(String(data: data, encoding: .utf8)!)

            expectation.fulfill()
        }
        task.resume()

        self.waitForExpectations(timeout: 10)
    }



    static var allTests: [(String, (CompatibilityTests) -> () throws -> Void)] {
        return [
            ("testEmpty", self.testEmpty),
            ("testSingle", self.testSingle),
            ("testDouble", self.testDouble),
        ]
    }
}

