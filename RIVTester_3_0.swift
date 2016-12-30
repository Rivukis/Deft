
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
public class RIVTester {
    private struct RIVTest {
        let description : String
        let executable : () -> Bool
        let expectedBehavior : String
        let pending : Bool
        let focused : Bool
    }
    
    private var tests = [RIVTest]()
    private var hasFocusedTest = false
    
    // MARK: Public
    
    public init() {}
    
    /**
     Adds a test.
     
     - Parameter description:       The description to output if the test is executed.
     - Parameter expectedBehavior:  The message to output if the test is executed and fails.
     - Parameter block:             The block to determine if the test succeeds or fails.
     */
    public func addTest(description: String, expectedBehavior: String, _ executable: @escaping () -> Bool) {
        tests.append(RIVTest(description: description, executable: executable, expectedBehavior: expectedBehavior, pending: false, focused: false))
    }
    
    /**
     Adds a focused test.
     
     - Important: If one or more focused tests are added, all non-focused tests will be treated as pending.
     
     - Parameter description:       The description to output if the test is executed.
     - Parameter expectedBehavior:  The message to output if the test is executed and fails.
     - Parameter block:             The block to determine if the test succeeds or fails.
     */
    public func faddTest(description: String, expectedBehavior: String, _ executable: @escaping () -> Bool) {
        hasFocusedTest = true
        tests.append(RIVTest(description: description, executable: executable, expectedBehavior: expectedBehavior, pending: false, focused: true))
    }
    
    /**
     Adds a pending test.
     
     - Warning: Pending tests will not be executed.
     - Note: This has the same function signature as its counterparts for ease of use.
     
     - Parameter description:       The description to output if the test is executed.
     - Parameter expectedBehavior:  The message to output if the test is executed and fails.
     - Parameter block:             The block to determine if the test succeeds or fails.
     */
    public func xaddTest(description: String, expectedBehavior: String, _ executable: @escaping () -> Bool) {
        tests.append(RIVTest(description: description, executable: executable, expectedBehavior: expectedBehavior, pending: true, focused: false))
    }
    
    /**
     Executes the tests.
     
     - Parameter autoPrintTests:    Specify if the resulting output should be printed. Defaults to true
     
     - Returns: The resulting output `String` that will/would be printed, specified by `autoPrintTests`.
     */
    public func executeTests(autoPrintTests shouldPrint: Bool = true) -> String {
        let result = processTests()
        
        if shouldPrint {
            print(result)
        }
        
        return result
    }
    
    // MARK: Private
    
    private func processTests() -> String {
        var result = ""
        var succeeded = 0
        var pending = 0
        
        for (index, test) in tests.enumerated() {
            result += testOutput(test: test, number: index + 1, succeeded: &succeeded, pending: &pending)
        }
        
        return result + endLine(totalCount: self.tests.count, succeeded: succeeded, pending: pending)
    }
    
    private func endLine(totalCount: Int, succeeded: Int, pending: Int) -> String {
        return "\nExecuted \(tests.count) test(s) | \(succeeded) succeeded | \(tests.count - succeeded - pending) failed | \(pending) pending"
    }
    
    private func testOutput(test: RIVTest, number: Int, succeeded : inout Int , pending : inout Int) -> String {
        let isPending = test.pending || (hasFocusedTest && !test.focused)
        if isPending {
            pending += 1
            return "> Test \(number): \(test.description)\n"
        }
        else if test.executable() {
            succeeded += 1
            return ". Test \(number): \(test.description)\n"
        }
        else {
            return "F Test \(number): \(test.description) -> \(test.expectedBehavior)\n"
        }
    }
}
