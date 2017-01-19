/**
 # Public Interface
 ## Adding Test(s)
 `addTest(description: String, failureMessage: String, _: () -> Bool)`
 
 `faddTest(description: String, failureMessage: String, _: () -> Bool)`
 
 `xaddTest(description: String, failureMessage: String, _: () -> Bool)`
 
 ## Executing Test(s)
 `executeTests(autoPrintTests: Bool = true)`
 
 # Output Notation
 "." : Test succeeded
 
 "F" : Test failed
 
 ">" : Test marked as pending
 */
public class TDDTester {
    private var tests: [TDDTest] = []
    private var hasFocusedTest = false
    
    // MARK: Public
    
    public init() {}
    
    /**
     Adds a test.
     
     - Parameter description:       The description to output if the test is executed.
     - Parameter expectedBehavior:  The message to output if the test is executed and fails.
     - Parameter given:             The block used to setup the test
     - Parameter when:              The block used as the action or scenario for the test
     - Parameter then:              The block to determine if the test succeeds or fails.
     */
    public func add(description: String, expectedBehavior: String, given: (() -> Void)? = nil, when: (() -> Void)? = nil, then: @escaping () -> Bool) {
        tests.append(TDDTest(given: given, when: when, then: then, description: description, expectedBehavior: expectedBehavior))
    }
    
    /**
     Adds a focused test.
     
     - Important: If one or more focused tests are added, all non-focused tests will be treated as pending.
     
     - Parameter description:       The description to output if the test is executed.
     - Parameter expectedBehavior:  The message to output if the test is executed and fails.
     - Parameter given:             The block used to setup the test
     - Parameter when:              The block used as the action or scenario for the test
     - Parameter then:              The block to determine if the test succeeds or fails.
     */
    public func fadd(description: String, expectedBehavior: String, given: (() -> Void)? = nil, when: (() -> Void)? = nil, then: @escaping () -> Bool) {
        hasFocusedTest = true
        tests.append(TDDTest(given: given, when: when, then: then, description: description, expectedBehavior: expectedBehavior, focused: true))
    }
    
    /**
     Adds a pending test.
     
     - Warning: Pending tests will not be executed.
     - Note: This has the same function signature as its counterparts for ease of use.
     
     - Parameter description:       The description to output if the test is executed.
     - Parameter expectedBehavior:  The message to output if the test is executed and fails.
     - Parameter given:             The block used to setup the test
     - Parameter when:              The block used as the action or scenario for the test
     - Parameter then:              The block to determine if the test succeeds or fails.
     */
    public func xadd(description: String, expectedBehavior: String, given: (() -> Void)? = nil, when: (() -> Void)? = nil, then: @escaping () -> Bool) {
        let test = TDDTest(given: given, when: when, then: then, description: description, expectedBehavior: expectedBehavior, pending: true)
        tests.append(test)
    }
    
    /**
     Executes the tests.
     
     - Parameter autoPrintTests:    Specify if the resulting output should be printed. Defaults to true
     
     - Returns: The resulting output `String` that will/would be printed, specified by `autoPrintTests`.
     */
    public func executeTests() {
        let result = processTests()
        print(result)
    }
    
    // MARK: Private
    
    private func processTests() -> String {
        var result = TestResult()
        
        for (index, test) in tests.enumerated() {
            result = result.resultByCombining(with: execute(test: test, number: index + 1))
        }
        
        return result.description + endLine(result: result)
    }
    
    private func endLine(result: TestResult) -> String {
        let failed = result.total - result.succeeded - result.pending
        let testText = result.total == 1 ? "test" : "tests"
        return "\nExecuted \(result.total) \(testText)\n | \(result.succeeded) succeeded\n | \(failed) failed\n | \(result.pending) pending"
    }
    
    private func execute(test: TDDTest, number: Int) -> TestResult {
        let output: String
        var pending = false
        var succeeded = false
        
        let isPending = test.pending || (hasFocusedTest && !test.focused)
        if isPending {
            pending = true
            output = "> Test \(number): \(test.presentableDescription())\n"
        }
        else if test.execute() {
            succeeded = true
            output = ". Test \(number): \(test.presentableDescription())\n"
        }
        else {
            output = "F Test \(number): \(test.presentableDescription()) -> \(test.presentableExpectedBehavior())\n"
        }
        
        return TestResult(description: output, total: 1, succeeded: (succeeded ? 1 : 0), pending: (pending ? 1 : 0))
    }
}

private class TDDTest {
    let given: (() -> Void)?
    let when: (() -> Void)?
    let then: () -> Bool
    let description: String
    let expectedBehavior : String
    let focused: Bool
    let pending: Bool
    
    init(given: (() -> Void)?, when: (() -> Void)?, then: @escaping () -> Bool, description: String, expectedBehavior: String, focused: Bool = false, pending: Bool = false) {
        self.given = given
        self.when = when
        self.then = then
        self.description = description
        self.expectedBehavior = expectedBehavior
        self.focused = focused
        self.pending = pending
    }
    
    func execute() -> Bool {
        given?()
        when?()
        return then()
    }
    
    func presentableDescription() -> String {
        return description.isEmpty ? "(description not provided)" : description
    }
    
    func presentableExpectedBehavior() -> String {
        return description.isEmpty ? "(expected behavior not provided)" : expectedBehavior
    }
}

private class TestResult {
    let description: String
    let total: Int
    let succeeded: Int
    let pending: Int
    
    init() {
        self.description = ""
        self.total = 0
        self.succeeded = 0
        self.pending = 0
    }
    
    init(description: String, total: Int, succeeded: Int, pending: Int) {
        self.description = description
        self.total = total
        self.succeeded = succeeded
        self.pending = pending
    }
    
    func resultByCombining(with other: TestResult) -> TestResult {
        return TestResult(description: description + other.description,
                          total: total + other.total,
                          succeeded: succeeded + other.succeeded,
                          pending: pending + other.pending)
    }
}
