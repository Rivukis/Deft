## Synopsis

A simple test driven development (TDD) helper file for Xcode playgrounds.

## Code Example

```
class FizzBuzz {
    func gameUpTo(max: Int) -> [String] {
        precondition(max > 0, "max must be more than zero")
        
        var result = ["Zero"]
        
        for answer in 1...max {
            let isDivisbleByThree = answer % 3 == 0
            let isDevisbleByFive = answer % 5 == 0
            
            if isDivisbleByThree && isDevisbleByFive {
                result.append("FizzBuzz")
            }
            else if isDivisbleByThree {
                result.append("Fizz")
            }
            else if isDevisbleByFive {
                result.append("Buzz")
            }
            else {
                result.append("\(answer)")
            }
        }
        return result
    }
}

// create the tester
let myTester = RIVTester()

// make your tests
let subject = FizzBuzz()

myTester.addTest(description: "amount of answers", failureMessage: "resulting array count should equal one more than the number passed in") {
    let result = subject.gameUpTo(10)
    return result.count == 11
}
myTester.addTest(description: "index zero", failureMessage: "should put 'Zero' for the first index") {
    let result = subject.gameUpTo(1)
    return result[0] == "Zero"
}
myTester.addTest(description: "normal numbers", failureMessage: "should return '1' and '2' for the first two answers") {
    let result = subject.gameUpTo(2)
    
    return result[1] == "1" && result[2] == "2"
}
myTester.addTest(description: "numbers divisible by 3", failureMessage: "should return Fizz for '3' and '6'") {
    let result = subject.gameUpTo(6)
    return result[3] == "Fizz" && result[6] == "Fizz"
}
myTester.addTest(description: "numbers divisible by 5", failureMessage: "should return Buzz for '5' and '10'") {
    let result = subject.gameUpTo(10)
    return result[5] == "Buzz" && result[10] == "Buzz"
}
myTester.addTest(description: "numbers divisible by 3 and 5", failureMessage: "should return FizzBuzz for '15' and '30'") {
    let result = subject.gameUpTo(30)
    return result[15] == "FizzBuzz" && result[30] == "FizzBuzz"
}

// execute the tests
myTester.executeTests()
```

## Motivation

Are building something complicated enough that you might make a mistake? Are you building it in an Xcode playground? Then ensure you don't break what you've built by testing it (or better yet through the practice of TDD) using this easy to drop in file that takes the tediousness out of testing in a playground

## Installation

- Download this file
- Open you Xcode playground
- Open the project navigator (CMD + 1)
- Select the 'Sources' folder
- 'Add files to "Sourcees"...' (CMA + OPT + A)
- Find and "Add" the downloaded file
- Start testing

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