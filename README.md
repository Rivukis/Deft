# Deft

Test Driven Development (TDD) framework for Xcode playgrounds that utilizes the console output for reporting.

Framework for adding tests using describes, contexts, its, beforesEachs, afterEachs, and/or a subjectAction. This is similar to what you might build if you were using [Cedar](https://github.com/pivotal/cedar) or [Quick/Nimble](https://github.com/Quick/Quick).

## Infomercial Explanation

Are you building something complicated enough that you might write a bug when implementing new features? Would you like to know when you make a mistake as soon as you make it instead of hours or even days later? Are you building it in an Xcode playground? Then ensure you don't break what you've built by testing it Or better yet through the practice of TDD/BDD! Using this easy to drop in file that takes the tediousness out of testing in a playground.

## Abilities

- Initiate testing using the `describe()` function
- Add describe scopes using `describe()`
- Add context scopes using `context()`
- Add it scopes using `it()`
- Add test setup using `beforeEach()`
- Add tear down code using `afterEach()`
- Add an action for all the tests using `subjectAction()`
- Add expectations in 'it' scopes using `expect().to()`
- Focus test(s) by adding 'f' in front of describes, contexts, and/or its (i.e. `fdescribe()`, `fcontext()`, `fit()`)
- Mark test(s) as pending by adding 'x' in front of describes, contexts, and/or its (i.e. `xdescribe()`, `xcontext()`, `xit()`)
- Run the playground and see the results in the console window (to view the console window use the shortcut: ⌘⇧Y)

## Example using Deft

```swift
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
describe("DataService") {
    var subject: DataService!
    var httpClient: FakeHTTPClient!

    beforeEach {
        httpClient = FakeHTTPClient()
        subject = DataService(httpClient: httpClient)
    }

    describe("getting data") {
        context("when data gets returned") {
            let expectedData = "im the data"

            beforeEach {
                httpClient.data = expectedData
            }

            it("should report the data") {
                expect(subject.getData()).toNot(beEmpty())
                expect(subject.getData()).to(equal(expectedData))
            }
        }

        context("when an error is returned") {
            context("when the error is 'no response'") {
                beforeEach {
                    httpClient.error = DataError.noResponse
                }

                it("should report back 'no network connection'") {
                    expect(subject.getData()).to(equal("no network connection"))
                }
            }

            context("when the error is 'bad data'") {
                beforeEach {
                    httpClient.data = "bad data"
                    httpClient.error = DataError.badData
                }

                it("should report back 'there seems to be problems on the server'") {
                    expect(subject.getData()).to(equal("there seems to be a problem with the server"))
                }
            }

            context("when the erro is unknown") {
                beforeEach {
                    httpClient.error = UnknownError.unknown
                }

                it("should report back 'hmmm something went wrong'") {
                    expect(subject.getData()).to(equal("hmmm something went wrong"))
                }
            }
        }

        context("when nothing is returned") {
            beforeEach {
                httpClient.data = nil
                httpClient.error = nil
            }

            it("should report back 'no data returned'") {
                expect(subject.getData()).to(equal("no data returned"))
            }
        }
    }
}
```

### Example Console Output

```
 Test: DataService
    Describe: getting data
       Context: when data gets returned
.         It: should report the data
       Context: when an error is returned
          Context: when the error is 'no response'
.            It: should report back 'no network connection'
          Context: when the error is 'bad data'
.            It: should report back 'there seems to be problems on the server'
          Context: when the erro is unknown
.            It: should report back 'hmmm something went wrong'
       Context: when nothing is returned
F         It: should report back 'no data returned'

 Failed on line: [120]

 Executed 5 tests
  |- 4 succeeded
  |- 1 failed
  |- 0 pending


```

## Matchers

Matchers are the way results are tested.

### Example Matchers

```swift
// equal matcher - passes if actualResult == expectedResult
expect(actualResult).to(equal(expectedResult))

// haveCount matcher - passes if actualArray has a count of 5
expect(actualArray).to(haveCount(5))

```

### Built-in Matchers

- equal - passes if actual is equal to expected
- beTrue - passes if actual is true
- beFalse - passes if actual is false
- beNil - passes if actual is nil
- be - passes if actual identical to expected
- beCloseTo - passes if actual is within 0.0001 of expected
- passComparison - passes if the comparison function returns true when actual and expected passed in
- haveCount - passes if actual has a count of expected (works with Collection types and Strings)
- beEmpty - passes if actual has a count of 0 (works with Collection types and Strings)
- throwError - passes if the wrapped function throws an error (can use a validator function for the error or can equate the error if Equatable)
- succeed - passes if the function returns true (used for custom testing)
- log - debugging matcher that allows you to execute code (mainly print statements) at the time `expect().to()`s are validated.

### Custom Matchers

You can make new matchers by providing a global function that returns `Matcher<A, E>` where `A` is the actual value's type and `E` is the expected value's type.
A Matcher's init takes in an evaluator closure. This closure is passed the actual value (the part passed into `expect("here")`).
The function should take in the expected value (the part passed into the matcher `to(customMatcher("here"))`).

```swift
// this matcher takes in a String as the actual value and an Int as the expected value.
public func haveCount(_ expected: Int) -> Matcher<String, Int> {
    return Matcher { actual in
        return actual.characters.count == expected
    }
}

// this matcher takes in a String as the actual and does not take in an expected value.
public func beEmpty() -> Matcher<String, Void> {
    return Matcher { actual in
        return actual.isEmpty
    }
}
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

## Installation

- Download the provided Deft.swift
- Open an Xcode playground
- Open the project navigator (COMMAND + 1)
- Select the 'Sources' folder <-- This is required
- 'Add files to "Sources"...' (CMA + OPT + A)
- Find and "Add" 'Deft.swift'
- Start Testing!

## Contributors

If you have an idea that can make this TDD helper better, please don't hesitate to submit a pull request!

## Author

Brian Radebaugh, rivukis@gmail.com

## License

Deft is available under the MIT license. See the LICENSE file for more info.
