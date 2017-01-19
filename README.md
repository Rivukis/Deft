# Deft

Simple testing frameworks for Xcode playgrounds that utilizes the console output for reporting.

## TDDTester

Framework for adding tests using the "given", "when", and "then" pattern. Can also be used to add tests using a single unnamed block. This is similar to what you might build if you were using XCTest.

### Abilities
- Add tests using `add()`
- Focus test(s) using `fadd()`
- Mark test(s) as pending using `xadd()`
- Run the playground and see the results in the console window (⌘⇧Y)

### Code Example

```
class FizzBuzz {
    func gameUpTo(max: Int) -> [String] {
        precondition(max > 0, "max must be more than zero")

        var result = ["Zero"]

        for answer in 1...max {
            if answer % 3 == 0 {
                result.append("Fizz")
            }
            else if answer % 5 == 0 {
                result.append("Buzz")
            }
            else {
                result.append("\(answer)")
            }
        }
        
        return result
    }
}

// Create the tester
let myTester = RIVTester()

// Make your tests
let subject = FizzBuzz()

myTester.add("amount of answers", expect: "resulting array count should equal one more than the number passed in") {
    let result = subject.gameUpTo(10)
    return result.count == 11
}
myTester.add("index zero", expect: "should put 'Zero' for the first index") {
    let result = subject.gameUpTo(1)
    return result[0] == "Zero"
}
myTester.add("normal numbers", expect: "should return '1' and '2' for the first two answers") {
    let result = subject.gameUpTo(2)
    return result[1] == "1" && result[2] == "2"
}
myTester.add("numbers divisible by 3", expect: "should return Fizz for '3' and '6'") {
    let result = subject.gameUpTo(6)
    return result[3] == "Fizz" && result[6] == "Fizz"
}
myTester.add("numbers divisible by 5", expect: "should return Buzz for '5' and '10'") {
    let result = subject.gameUpTo(10)
    return result[5] == "Buzz" && result[10] == "Buzz"
}
myTester.add("numbers divisible by 3 and 5", expect: "should return FizzBuzz for '15' and '30'") {
    let result = subject.gameUpTo(30)
    return result[15] == "FizzBuzz" && result[30] == "FizzBuzz"
}

// Execute the tests
myTester.executeTests()
```

### Example Console Output

```
. Test 0: amount of answers
. Test 1: index zero
. Test 2: normal numbers
. Test 3: numbers divisible by 3
. Test 4: numbers divisible by 5
F Test 5: numbers divisible by 3 and 5

Executed 6 tests
 | 5 succeeded
 | 1 failed
 | 0 pending
```

## BDDTester

Framework for adding tests using describes, contexts, its, beforesEachs, afterEachs, and/or a subjectAction. This is similar to what you might build if you were using Cedar or Quick/Nimble.

### Abilities
- Initiate testing using the global `test()` function
- Add describe scopes using `describe()`
- Add context scopes using `context()`
- Add tests using `it()`
- Add test setup using `beforeEach()`
- Add tear down code using `afterEach()`
- Add an action for all the tests using `subjectAction()`
- Focus test(s) by adding 'f' in front of describes, contexts, and/or its
- Mark test(s) as pending by adding 'x' in front of describes, contexts, and/or its
- Run the playground and see the results in the console window (⌘⇧Y)

### Code Example

```
// Example Types
enum DataError: Error {
    case noResponse
    case badData
}

enum UnknownError: Error {
    case unknown
}

protocol HTTPClient {
    func getData() -> (data: String?, error: Error?)
}

class FakeHTTPClient: HTTPClient {
    var data: String?
    var error: Error?
    
    func getData() -> (data: String?, error: Error?) {
        return (data, error)
    }
}

// Subject under test
class DataService {
    let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    func getData() -> String {
        let result = httpClient.getData()
        
        if let error = result.error {
            if let error = error as? DataError {
                switch error {
                case .noResponse:
                    return "no network connection"
                case .badData:
                    return "there seems to be a problem with the server"
                }
            }
            
            return "hmmm something went wrong"
        }
        
        if let data = result.data {
            return data
        }
        
        return ""
    }
}

// Testing!
test("DataService") {
    var subject: DataService!
    var httpClient: FakeHTTPClient!
    
    beforeEach($0) {
        httpClient = FakeHTTPClient()
        subject = DataService(httpClient: httpClient)
    }
    
    describe("getting data", $0) {
        context("when data gets returned", $0) {
            let expectedData = "im the data"
            
            beforeEach($0) {
                httpClient.data = expectedData
            }
            
            it("should report the data", $0) {
                return subject.getData() == expectedData
            }
        }
        
        context("when an error is returned", $0) {
            context("when the error is 'no response'", $0) {
                beforeEach($0) {
                    httpClient.error = DataError.noResponse
                }
                
                it("should report back 'no network connection'", $0) {
                    return subject.getData() == "no network connection"
                }
            }
            
            context("when the error is 'bad data'", $0) {
                beforeEach($0) {
                    httpClient.data = "bad data"
                    httpClient.error = DataError.badData
                }
                
                it("should report back 'there seems to be problems on the server'", $0) {
                    return subject.getData() == ""
                }
            }
            
            context("when the erro is unknown", $0) {
                beforeEach($0) {
                    httpClient.error = UnknownError.unknown
                }
                
                it("should report back 'hmmm something went wrong'", $0) {
                    return subject.getData() == "hmmm something went wrong"
                }
            }
        }
        
        context("when nothing is returned", $0) {
            beforeEach($0) {
                httpClient.data = nil
                httpClient.error = nil
            }
            
            it("should report back an empty string", $0) {
                return subject.getData() == ""
            }
        }
    }
}
```

### Example Console Output

```
 Describe: DataService
    Describe: getting data
       Context: when data gets returned
.         It: should report the data
       Context: when an error is returned
          Context: when the error is 'no response'
.            It: should report back 'no network connection'
          Context: when the error is 'bad data'
F            It: should report back 'there seems to be problems on the server'
          Context: when the erro is unknown
.            It: should report back 'hmmm something went wrong'
       Context: when nothing is returned
.         It: should report back an empty string

Executed 5 tests
 |- 4 succeeded
 |- 1 failed
 |- 0 pending
```

## Note
- Playgrounds seem to work better if you turn off the auto run feature
    - Turn off by moving the mouse over the little blue play button in the bottom left of the window, click and hold until a menu shows up, and choose "Manually Run"
- If you have "Manually Run" turned on in the Xcode playground, I recommend adding a keyboard shortcut to "Run Playground"
    - I found (^R) to be a good choice as it is the closest thing to (⌘R) without running into other shortcuts. Also Xcode doesn't allow you to use (⌘R).

## Key
 - "." : Test succeeded
 - "F" : Test failed
 - ">" : Test marked as pending

## Motivation

Are you building something complicated enough that you might make a mistake? Are you building it in an Xcode playground? Then ensure you don't break what you've built by testing it (or better yet through the practice of TDD/BDD!). Using this easy to drop in file that takes the tediousness out of testing in a playground.

## Installation

- Download the provided RIVTester.swift
- Open an Xcode playground
- Open the project navigator (COMMAND + 1)
- Select the 'Sources' folder <-- This is required
- 'Add files to "Sourcees"...' (CMA + OPT + A)
- Find and "Add" 'TDDTester.swift' or 'BDDTester.swift'
- Start Testing!

## Contributors

If you have an idea that can make this TDD helper better, please don't hesitate to submit a pull request.

## License

MIT License

Copyright (c) [2016] [Brian Radebaugh]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.