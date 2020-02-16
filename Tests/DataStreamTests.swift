//
//  DataStreamTests.swift
//
//  Copyright (c) 2020 Alamofire Software Foundation (http://alamofire.org/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Alamofire
import XCTest

final class DataStreamTests: BaseTestCase {
    func testThatDataCanBeStreamed() {
        // Given
        let expectedSize = 1000
        var accumulatedData = Data()
        var response: HTTPURLResponse?
        let expect = expectation(description: "stream should complete")

        // When
        AF.streamRequest(URLRequest.makeHTTPBinRequest(path: "bytes/\(expectedSize)")).responseStream { output in
            switch output {
            case let .data(data): accumulatedData.append(data)
            case let .complete(_, resp, _):
                response = resp
                expect.fulfill()
            }
        }

        waitForExpectations(timeout: timeout)

        // Then
        XCTAssertEqual(response?.statusCode, 200)
        XCTAssertEqual(accumulatedData.count, expectedSize)
    }

    func testThatDataCanBeStreamedManyTimes() {
        // Given
        let expectedSize = 1000
        var firstAccumulatedData = Data()
        var firstResponse: HTTPURLResponse?
        let firstExpectation = expectation(description: "first stream should complete")
        var secondAccumulatedData = Data()
        var secondResponse: HTTPURLResponse?
        let secondExpectation = expectation(description: "second stream should complete")

        // When
        AF.streamRequest(URLRequest.makeHTTPBinRequest(path: "bytes/\(expectedSize)"))
            .responseStream { output in
                switch output {
                case let .data(data): firstAccumulatedData.append(data)
                case let .complete(_, resp, _):
                    firstResponse = resp
                    firstExpectation.fulfill()
                }
            }
            .responseStream { output in
                switch output {
                case let .data(data): secondAccumulatedData.append(data)
                case let .complete(_, resp, _):
                    secondResponse = resp
                    secondExpectation.fulfill()
                }
            }

        waitForExpectations(timeout: timeout)

        // Then
        XCTAssertEqual(firstResponse?.statusCode, 200)
        XCTAssertEqual(firstAccumulatedData.count, expectedSize)
        XCTAssertEqual(secondResponse?.statusCode, 200)
        XCTAssertEqual(secondAccumulatedData.count, expectedSize)
    }
}
