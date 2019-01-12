
// MARK: - Matcher

/**
 This object is used to verify results using `expect().to()`.

 New matchers are made by providing a global function that returns this type

 - Actual: The expected type passed into the `expect()` function.
 - Expected: The expected type passed into the global function.

 ## Global Matcher Function Example ##
 ```swift
 public func equal<T: Equatable>(_ expected: T) -> Matcher<T?, T> {
     return Matcher { actual in
         return actual == expected
     }
 }
 ```
 */
public class Matcher<Actual, Expected> {
    let evaluator: (Actual) -> Bool

    /**
     Creates a new Matcher.

     - Parameter evaluator: the closure that is executed during tests. Return true or false to indicate whether or not the actual value passed validation.
     */
    public init(_ evaluator: @escaping (Actual) -> Bool) {
        self.evaluator = evaluator
    }

    func execute(actual: Actual) -> Bool {
        return evaluator(actual)
    }
}

// MARK: - Built-in Matcher Functions

/**
 Equal Matcher

 Validates that two objects are equal using the `Equatable` protocol.

 ## Example ##
 ```swift
 expect("value").to(equal("value"))
 ```

 - Parameter expected: The object to be compared to the actual value.
 */
public func equal<T: Equatable>(_ expected: T) -> Matcher<T?, T> {
    return Matcher { actual in
        return actual == expected
    }
}

/**
 Be True Matcher

 Validates that the actual value is true.

 ## Example ##
 ```swift
 expect(true).to(beTrue())
 ```
 */
public func beTrue() -> Matcher<Bool, Void> {
    return Matcher { actual in
        return actual
    }
}

/**
 Be False Matcher

 Validates that the actual value is false.

 ## Example ##
 ```swift
 expect(false).to(beFalse())
 ```
 */
public func beFalse() -> Matcher<Bool, Void> {
    return Matcher { actual in
        return !actual
    }
}

/**
 Be Nil Matcher

 Validates that the actual value is nil.

 ## Example ##
 ```swift
 let myClass: MyClass? = nil
 expect(myClass).to(beNil())
 ```
 */
public func beNil<T>() -> Matcher<T?, Void> {
    return Matcher { actual in
        return actual == nil
    }
}

/**
 Be Matcher

 Validates that two objects are the same instance.

 ## Example ##
 ```swift
 let myClass = MyClass()
 expect(myClass).to(be(myClass))
 ```

 - Parameter expected: The object to be compared to the actual value.
 */
public func be<T: AnyObject>(_ expected: T) -> Matcher<T, T> {
    return Matcher { actual in
        return actual === expected
    }
}

/**
 Be Close To Matcher

 Validates that the actual value is close to expected value.

 ## Example ##
 ```swift
 expect(5.0).to(beCloseTo(5.0))
 expect(5.0).to(beCloseTo(5.0, maxDelta: 0.1))
 ```

 - Parameter expected: The object to be compared to the actual value.
 - Parameter maxDelta: The maximum difference that the actual value can be from the expected value and still pass validation. Defaults to 0.0001
 */
public func beCloseTo(_ expected: Double, maxDelta: Double = 0.0001) -> Matcher<Double, Double> {
    return Matcher { actual in
        return abs(actual - expected) <= maxDelta
    }
}

/**
 Be Close To Matcher

 Validates that the actual value is close to expected value.

 ## Example ##
 ```swift
 expect(5.0).to(beCloseTo(5.0))
 expect(5.0).to(beCloseTo(5.0, maxDelta: 0.1))
 ```

 - Parameter expected: The object to be compared to the actual value.
 - Parameter maxDelta: The maximum difference that the actual value can be from the expected value and still pass validation. Defaults to 0.0001
 */
public func beCloseTo(_ expected: Float, maxDelta: Float = 0.0001) -> Matcher<Float, Float> {
    return Matcher { actual in
        return abs(actual - expected) <= maxDelta
    }
}

/**
 Pass Comparison Matcher

 Validates that the comparison function returns true when the acutal value is passed in as the left/first argument and the expected value as the right/second argument.

 ## Example ##
 ```swift
 expect(5).to(passComparison(<=, 10))
 ```

 - Parameter comparisonFunction: The object to be compared to the actual value.
 - Parameter expected: The left/second argument to passed into the comparison function.
 */
public func passComparison<T: Comparable>(_ comparisonFunction: @escaping (T, T) -> Bool, _ expected: T) -> Matcher<T, T> {
    return Matcher { actual in
        return comparisonFunction(actual, expected)
    }
}

/**
 Have Count Matcher

 Validates that the `Collection` has the expected count.

 ## Example ##
 ```swift
 expect([1, 2, 3]).to(haveCount(3))
 ```

 - Parameter expectedCount: The expected count
 */
public func haveCount<C: Collection>(_ expectedCount: Int) -> Matcher<C, Int> {
    return Matcher { actual in
        return actual.count == expectedCount
    }
}

/**
 Have Count Matcher

 Validates that the string's `CharacterView` has the expected count.

 ## Example ##
 ```swift
 expect("value").to(haveCount(5))
 ```

 - Parameter expectedCount: The expected count
 */
public func haveCount(_ expectedCount: Int) -> Matcher<String, Int> {
    return Matcher { actual in
        return actual.count == expectedCount
    }
}

/**
 Contain Matcher

 Validates that the `Collection` contains the expected value.

 ## Example ##
 ```swift
 expect([1, 2, 3]).to(contain(2))
 ```
 
 - Parameter expectedValue: The expected value
 */
public func contain<T: Equatable>(_ expectedValue: T) -> Matcher<[T], T> {
    return Matcher { actual in
        return actual.contains(expectedValue)
    }
}

/**
 Contain Matcher

 Validates that the `Collection` contains an element that satisfies the predicate.

 ## Example ##
 ```swift
 let person = Person(age: 21)
 expect([person]).to(contain { $0.age == 21 })
 ```
 
 - Parameter predicate: the closure used to determine in an element satisfies the predicate
 */
public func contain<T>(where predicate: @escaping (T) -> Bool) -> Matcher<[T], T> {
    return Matcher { actual in
        return actual.contains(where: predicate)
    }
}

/**
 Be Empty Matcher

 Validates that the `Collection` has a count of 0.

 ## Example ##
 ```swift
 expect([]).to(beEmpty())
 ```
 */
public func beEmpty<C: Collection>() -> Matcher<C, Void> {
    return Matcher { actual in
        return actual.count == 0
    }
}

/**
 Be Empty Matcher

 Validates that the string's `CharacterView` has a count of 0.

 ## Example ##
 ```swift
 expect("").to(beEmpty())
 ```
 */
public func beEmpty() -> Matcher<String, Void> {
    return Matcher { actual in
        return actual.isEmpty
    }
}

/**
 Throw Error Matcher

 Validates that wrapping function throws an error.

 Can also validate the error using the optionally passed in function. If the error validator function is nil, then matcher will ONLY validate if an error was thrown.

 ## Example ##
 ```swift
 expect({ 
     try subject.throwingFunction()
 }).to(throwError())

 expect({ 
     try subject.throwingFunction()
 }).to(throwError(errorVerifier: { error in
     let actualError = error as! MyError
     return actual.name == "expected name"
 }))
 ```

 - Parameter errorVerifier: The closure used to determine if the error thrown is the expected error. Defaults to nil.
 */
public func throwError(errorVerifier: ((Error) -> Bool)? = nil) -> Matcher<() throws -> Void, Void> {
    return Matcher { actual in
        do {
            try actual()
        } catch let error {
            if let errorVerifier = errorVerifier {
                return errorVerifier(error)
            }

            return true
        }

        return false
    }
}

/**
 Throw Error Matcher

 Validates that wrapping function throws an error equal to the expected error.

 - Note: This matcher will also fail validation if the actual error thrown is NOT the same type as the expected error.

 ## Example ##
 ```swift
 expect({
     try subject.throwingFunction()
 }).to(throwError(error: MyError()))
 ```

 - Parameter error: The error to be compared to the actual error thrown.
 */
public func throwError<T: Error & Equatable>(error: T) -> Matcher<() throws -> Void, T> {
    return Matcher { actual in
        do {
            try actual()
        } catch let actualError {
            if let actualError = actualError as? T {
                return actualError == error
            }

            return false
        }

        return false
    }
}

/**
 Succeed Matcher

 Validates that passed function returns true.

 ## Example ##
 ```swift
 expect({
     if case .one = myEnum {
         return true
     }

     return false
 }).to(succeed())
 ```

 - Parameter error: The error to be compared to the actual error thrown.
 */
public func succeed() -> Matcher<() -> Bool, Void> {
    return Matcher { actual in
        return actual()
    }
}

/**
 Log Matcher

 This matcher is only used for debugging purposes. This matcher exists because of the nature of timing during tests and since breakpoints are not yet available in playgrounds. This matcher allows you to call print statements at the time the enclosing `it` scope executes it's `expect().to()`.

 If a print statement is executed directly in the enclosing `it` scope then it will NOT be executed at the same time the `expect().to()`s are evaluated but instead during Deft's scope capturing process. During this capturing process no `beforeEach`s, `afterEach`s, and `expect().to()`s are executed.

 ## Example ##
 ```swift
 it("should ...") {
     print("this is too early and will not reflect any changes made when `beforeEach` scopes are executed.")

     expect({
         print("useful debugging information is printed here as all `beforeEach` scopes for this `it` scope have executed and none of the `afterEach` scopes have been executed.")
     }).to(log())
 }
 ```
 */
public func log() -> Matcher<() -> Void, Void> {
    return Matcher { actual in
        actual()
        return true
    }
}

// MARK: - TDD Framework

private struct Constant {
    static let levelSpace = "   "
    static let emptyTitle = ""

    struct OutPutPrefix {
        static let topLevel = "Test: "
        static let describe = "Describe: "
        static let context = "Context: "
        static let group = "Group: "
        static let it = "It: "

        static let focused = "F-"
        static let pending = "X-"
    }

    struct SingleCharacter {
        static let blank = " "
        static let success = "."
        static let failure = "F"
        static let pending = ">"
    }
}

private struct I18n {
    enum Key {
        case tooManySubjectActions
        case newScopesWhileExecuting
        case stepOutsideOfScope(StepType)
        case itOutsideOfScope
        case expectOutsideOfIt
        case notAllowedInIt(String)
        case lineOutput(text: String, level: Int, firstCharacter: String)
        case endLine(totalCount: Int, succeeded: Int, pending: Int)
        case failureOutputLine(failureLines: [Int])
    }

    static func t(_ key: Key) -> String {
        switch key {
        case .tooManySubjectActions:
            return "Only one \"subjectAction()\" per `it`."
        case .newScopesWhileExecuting:
            return "Tried to add a scope during a test. This is probably caused be a test block (describe, it, beforeEach, etc.) is defined inside an `it` block."
        case .stepOutsideOfScope(let type):
            return "`\(type)`s must be inside a `describe` or `context` scope."
        case .itOutsideOfScope:
            return "`it`s must be inside a `describe` or `context` scope."
        case .expectOutsideOfIt:
            return "`expects`s must be inside an `it` scope."
        case .notAllowedInIt(let string):
            return "`\(string)` not allowed in `it` scope."
        case .lineOutput(let text, let level, let firstCharacter):
            let space = String(repeating: Constant.levelSpace, count: level)
            return firstCharacter + space + text + "\n"
        case .endLine(let totalCount, let succeeded, let pending):
            let testText = totalCount == 1 ? "test" : "tests"
            return "\n Executed \(totalCount) \(testText)\n  |- \(succeeded) succeeded\n  |- \(totalCount - succeeded - pending) failed\n  |- \(pending) pending\n\n"
        case .failureOutputLine(let failureLines):
            guard !failureLines.isEmpty else { return "" }
            let linesString = failureLines.count == 1 ? "line" : "lines"
            return "\n Failed on " + linesString + ": [" + failureLines.map{"\($0)"}.joined(separator: ", ") + "]\n"
        }
    }
}

private protocol TrackedScope {
    func add(_ scope: Scope)
    func add(_ step: Step)
    func add(_ it: It)
}

private enum StepType {
    case beforeEach
    case subjectAction
    case afterEach
}

private enum ScopeType {
    case topLevel
    case describe
    case context
    case group

    var outputPrefix: String {
        switch self {
        case .topLevel: return Constant.OutPutPrefix.topLevel
        case .describe: return Constant.OutPutPrefix.describe
        case .context: return Constant.OutPutPrefix.context
        case .group: return Constant.OutPutPrefix.group
        }
    }
}

private enum Mark {
    case none
    case focused
    case pending
}

private class TestResult {
    let description: String
    let total: Int
    let succeeded: Int
    let pending: Int
    let failureLines: [Int]

    init(description: String = "", total: Int = 0, succeeded: Int = 0, pending: Int = 0, failureLines: [Int] = []) {
        self.description = description
        self.total = total
        self.succeeded = succeeded
        self.pending = pending
        self.failureLines = failureLines
    }

    static func + (lhs: TestResult, rhs: TestResult) -> TestResult {
        return TestResult(description: lhs.description + rhs.description,
                          total: lhs.total + rhs.total,
                          succeeded: lhs.succeeded + rhs.succeeded,
                          pending: lhs.pending + rhs.pending,
                          failureLines: lhs.failureLines + rhs.failureLines)
    }
}

private class Expect {
    private let captured: () -> Bool
    private let line: Int
    private let negativeTest: Bool

    init<A, E>(actual: A, matcher: Matcher<A, E>, line: Int, negativeTest: Bool) {
        self.captured = { matcher.execute(actual: actual) }
        self.line = line
        self.negativeTest = negativeTest
    }

    private func execute() -> Bool {
        let result = captured()
        return result && !negativeTest || !result && negativeTest
    }

    static func execute(_ expects: [Expect]) -> (Bool, [Int]) {
        var failedLines = [Int]()
        var allSucceeded = true

        for expect in expects {
            let success = expect.execute()

            if !success {
                failedLines.append(expect.line)
                allSucceeded = false
            }
        }

        return (allSucceeded, failedLines)
    }
}

/**
 This type is used to capture the actual value passed into `expect()` and the matcher passed into `to()`.

 This type should NOT be used directly. Use `expect().to()` instead.
 */
public class ExpectPartOne<A, E> {
    let actual: A
    let line: Int

    init(actual: A, line: Int) {
        self.actual = actual
        self.line = line
    }

    /**
     Captures the matcher to be used for this expectation.

     - Parameter matcher: The matcher to be used for validation.
     */
    public func to(_ matcher: Matcher<A, E>) {
        guard let currentScope = TestScope.currentTestScope else {
            fatalError(I18n.t(.expectOutsideOfIt))
        }

        let expect = Expect(actual: actual, matcher: matcher, line: line, negativeTest: false)
        currentScope.intake(expect)
    }

    /**
     Captures the matcher to be used for this expectation.

     Used to reverse the validation of a matcher. If the matcher passes validation then the test will fail and vise versa.

     - Note: Exactly the same as `notTo()`

     - Parameter matcher: The matcher to be used for validation.
     */
    public func toNot(_ matcher: Matcher<A, E>) {
        guard let currentScope = TestScope.currentTestScope else {
            fatalError(I18n.t(.expectOutsideOfIt))
        }

        let expect = Expect(actual: actual, matcher: matcher, line: line, negativeTest: true)
        currentScope.intake(expect)
    }

    /**
     Captures the matcher to be used for this expectation.

     Used to reverse the validation of a matcher. If the matcher passes validation then the test will fail and vise versa.

     - Note: Exactly the same as `toNot()`

     - Parameter matcher: The matcher to be used for validation.
     */
    public func notTo(_ matcher: Matcher<A, E>) {
        toNot(matcher)
    }
}

private class It {
    private let title: String
    private let mark: Mark

    let closure: () -> Void

    var expects: [Expect] = []
    var underFocus: Bool = false
    var underPending: Bool = false

    var actingFocused: Bool {
        return mark == .focused || underFocus
    }

    var actingPending: Bool {
        return mark == .pending || underPending
    }

    var displayableTitle: String {
        let prePrefix: String
        switch mark {
        case .none: prePrefix = ""
        case .focused: prePrefix = Constant.OutPutPrefix.focused
        case .pending: prePrefix = Constant.OutPutPrefix.pending
        }

        return prePrefix + Constant.OutPutPrefix.it + (title.isEmpty ? Constant.emptyTitle : title)
    }

    init(title: String, mark: Mark, closure: @escaping () -> Void) {
        self.title = title
        self.mark = mark
        self.closure = closure
    }

    func process(underFocus: Bool, underPending: Bool) {
        self.underFocus = underFocus
        self.underPending = underPending
    }

    func add(_ expect: Expect) {
        expects.append(expect)
    }

    // MARK: - Private

    private func shouldExecute(isSomethingFocused: Bool) -> Bool {
        if actingPending {
            return false
        }

        if isSomethingFocused {
            return actingFocused
        }

        return true
    }

    // MARK: - Static

    static func execute(_ its: [It], level: Int, steps: [Step], isSomethingFocused: Bool, inGroup: Bool) -> TestResult {
        if inGroup {
            return executeGroup(its, level: level, steps: steps, isSomethingFocused: isSomethingFocused)
        } else {
            return its.reduce(TestResult()) { $0 + executeGroup([$1], level: level, steps: steps, isSomethingFocused: isSomethingFocused) }
        }
    }

    // MARK: - Private Static

    private static func executeGroup(_ its: [It], level: Int, steps: [Step], isSomethingFocused: Bool) -> TestResult {
        let hasTestsToRun = its.reduce(false) { $0 || $1.shouldExecute(isSomethingFocused: isSomethingFocused) }
        guard hasTestsToRun else {
            return its.reduce(TestResult()) {
                let testDescription = I18n.t(.lineOutput(text: $1.displayableTitle, level: level, firstCharacter: Constant.SingleCharacter.pending))
                return $0 + TestResult(description: testDescription, total: 1, pending: 1)
            }
        }
        guard let currentScope = TestScope.currentTestScope else {
            fatalError(I18n.t(.itOutsideOfScope))
        }

        let beforeEachs = steps.filter { $0.type == .beforeEach }
        let subjectActions = steps.filter { $0.type == .subjectAction }
        let afterEachs = steps.filter { $0.type == .afterEach }

        guard subjectActions.count <= 1 else {
            fatalError(I18n.t(.tooManySubjectActions))
        }

        beforeEachs.forEach { $0.closure() }
        subjectActions.forEach { $0.closure() }
        its.forEach { currentScope.process($0) }

        let result = its.reduce(TestResult()) {
            guard $1.shouldExecute(isSomethingFocused: isSomethingFocused) else {
                let testDescription = I18n.t(.lineOutput(text: $1.displayableTitle, level: level, firstCharacter: Constant.SingleCharacter.pending))
                return $0 + TestResult(description: testDescription, total: 1, pending: 1)
            }

            let (success, failureLines) = Expect.execute($1.expects)
            let outcomeSymbol = success ? Constant.SingleCharacter.success : Constant.SingleCharacter.failure
            let testDescription = I18n.t(.lineOutput(text: $1.displayableTitle, level: level, firstCharacter: outcomeSymbol))
            return $0 + TestResult(description: testDescription, total: 1, succeeded: success ? 1 : 0, failureLines: failureLines)
        }

        afterEachs.reversed().forEach { $0.closure() }

        return result
    }
}

private class Step {
    let type: StepType
    let closure: () -> Void

    init(type: StepType, _ closure: @escaping () -> Void) {
        self.type = type
        self.closure = closure
    }
}

private class Scope: TrackedScope {
    private let title: String
    private let mark: Mark

    let type: ScopeType

    private var underFocus: Bool = false
    private var underPending: Bool = false
    private var steps: [Step] = []
    private var its: [It] = []
    private var subScopes: [Scope] = []

    private var actingFocused: Bool {
        return mark == .focused || underFocus
    }

    private var actingPending: Bool {
        return mark == .pending || underPending
    }

    private var displayableTitle: String {
        let prePrefix: String
        switch mark {
        case .none: prePrefix = ""
        case .focused: prePrefix = Constant.OutPutPrefix.focused
        case .pending: prePrefix = Constant.OutPutPrefix.pending
        }

        let prefix: String
        switch type {
        case .topLevel: prefix = prePrefix + Constant.OutPutPrefix.topLevel
        case .describe: prefix = prePrefix + Constant.OutPutPrefix.describe
        case .context: prefix = prePrefix + Constant.OutPutPrefix.context
        case .group: prefix = prePrefix + Constant.OutPutPrefix.group
        }

        let displayableDescription = title.isEmpty ? Constant.emptyTitle : title

        return prefix + displayableDescription
    }

    var hasActiveFocus: Bool {
        if actingPending {
            return false
        } else {
            let subScopeHasFocus = subScopes.reduce(false) { $0 || $1.hasActiveFocus }
            let itHasFocus = its.reduce(false) { $0 || $1.actingFocused }
            return subScopeHasFocus || itHasFocus || actingFocused
        }
    }

    init(type: ScopeType, title: String, mark: Mark) {
        self.type = type
        self.title = title
        self.mark = mark
    }

    func process(underFocus: Bool, underPending: Bool) {
        self.underFocus = underFocus
        self.underPending = underPending

        its.forEach { $0.process(underFocus: actingFocused, underPending: actingPending) }
        subScopes.forEach { $0.process(underFocus: actingFocused, underPending: actingPending) }
    }

    // MARK: - TrackerScope Protocol

    func add(_ step: Step) {
        steps.append(step)
    }

    func add(_ it: It) {
        its.append(it)
    }

    func add(_ scope: Scope) {
        subScopes.append(scope)
    }

    // MARK: - Static

    static func execute(_ scopes: [Scope], isSomethingFocused: Bool, level: Int = 0, accumulatedSteps: [Step] = []) -> TestResult {
        return scopes.reduce(TestResult()) {
            let aggregatedSteps = accumulatedSteps + $1.steps

            let scopeDescriptionResult = TestResult(description: I18n.t(.lineOutput(text: $1.displayableTitle, level: level, firstCharacter: Constant.SingleCharacter.blank)))
            let itsResult = It.execute($1.its, level: level + 1, steps: aggregatedSteps, isSomethingFocused: isSomethingFocused, inGroup: $1.type == .group)
            let subScopesResult = execute($1.subScopes, isSomethingFocused: isSomethingFocused, level: level + 1, accumulatedSteps: aggregatedSteps)

            return $0 + scopeDescriptionResult + itsResult + subScopesResult
        }
    }
}

private class Tracker {
    var scopes: [TrackedScope]
    var it: It?

    init(rootScope: TrackedScope) {
        self.scopes = [rootScope]
    }

    var currentScope: TrackedScope {
        return scopes.last!
    }

    func intake(_ scope: Scope, closure: () -> Void) {
        scopes.last!.add(scope)
        scopes.append(scope)
        closure()
        scopes.removeLast()
    }

    func intake(_ it: It) {
        scopes.last!.add(it)
    }

    func intake(_ step: Step) {
        scopes.last!.add(step)
    }

    func process(_ it: It) {
        self.it = it
        it.closure()
        self.it = nil
    }

    func intake(_ expect: Expect) {
        guard let it = it else {
            fatalError(I18n.t(.expectOutsideOfIt))
        }
        it.add(expect)
    }
}

private class TestScope: TrackedScope {
    static var currentTestScope: TestScope?

    private let tracker: Tracker
    private let rootScope: Scope

    private var isExecuting = false

    init(title: String, closure: () -> Void, mark: Mark) {
        rootScope = Scope(type: .topLevel, title: title, mark: mark)
        self.tracker = Tracker(rootScope: rootScope)

        TestScope.currentTestScope = self

        closure()
    }

    func intake(_ scope: Scope, closure: () -> Void) {
        ensureNotExecuting()
        tracker.intake(scope, closure: closure)
    }

    func intake(_ it: It) {
        ensureNotExecuting()
        tracker.intake(it)
    }

    func intake(_ step: Step) {
        ensureNotExecuting()
        tracker.intake(step)
    }

    func intake(_ expect: Expect) {
        guard isExecuting else {
            fatalError(I18n.t(.expectOutsideOfIt))
        }
        tracker.intake(expect)
    }

    func process(_ it: It) {
        tracker.process(it)
    }

    func execute() {
        isExecuting = true
        rootScope.process(underFocus: false, underPending: false)
        let result = Scope.execute([rootScope], isSomethingFocused: rootScope.hasActiveFocus)
        let failureLine = I18n.t(.failureOutputLine(failureLines: result.failureLines))
        let endLine = I18n.t(.endLine(totalCount: result.total, succeeded: result.succeeded, pending: result.pending))
        print(result.description + failureLine + endLine)
        isExecuting = false
    }

    // MARK: - Private

    private func ensureNotExecuting() {
        guard !isExecuting else {
            fatalError(I18n.t(.newScopesWhileExecuting))
        }
    }

    // MARK: - TrackedScope Protocol

    func add(_ scope: Scope) {
        rootScope.add(scope)
    }

    func add(_ step: Step) {
        rootScope.add(step)
    }

    func add(_ it: It) {
        rootScope.add(it)
    }
}

// MARK: - Scopes

/**
 Adds a describe scope.

 Describe scopes are normally used to encompass the subject under test or a specific behavior of the subject under test.

 - Parameter title: The `describe`'s title that is included in the test output.
 - Parameter closure: The `describe` scope to be executed during testing.
 */
public func describe(_ title: String, _ closure: () -> Void) {
    intakeScope(type: .describe, title, closure, mark: .none)
}

/**
 Adds a focused describe scope.

 Describe scopes are normally used to encompass the subject under test or a specific behavior of the subject under test.

 - Warning: If one or more focused tests/scopes are added, all non-focused tests/scopes outside of this `fdescribe()` will be treated as pending.
 - Note: This has the same function signature as `describe()` for ease of use.

 - Parameter title: The `describe`'s title that is included in the test output.
 - Parameter closure: The `describe` scope to be executed during testing.
 */
public func fdescribe(_ title: String, _ closure: () -> Void) {
    intakeScope(type: .describe, title, closure, mark: .focused)
}

/**
 Adds a pending describe scope.

 Describe scopes are normally used to encompass the subject under test or a specific behavior of the subject under test.

 - Warning: Tests within this `xdescribe()` will be marked as pending regardless of any focus.
 - Note: This has the same function signature as `describe()` for ease of use.

 - Parameter title: The `describe`'s title that is included in the test output.
 - Parameter closure: The `describe` scope to be executed during testing.
 */
public func xdescribe(_ title: String, _ closure: () -> Void) {
    intakeScope(type: .describe, title, closure, mark: .pending)
}

/**
 Adds a context scope.

 Context scopes are normally used to encompass a scenario that the subject under test or a specific behavior of the subject under test has to account for.

 - Parameter title: The `context`'s title that is included in the test output.
 - Parameter closure: The `context` scope to be executed during testing.
 */
public func context(_ title: String, _ closure: () -> Void) {
    intakeScope(type: .context, title, closure, mark: .none)
}

/**
 Adds a focused context scope.

 Context scopes are normally used to encompass a scenario that the subject under test or a specific behavior of the subject under test has to account for.

 - Warning: If one or more focused tests/scopes are added, all non-focused tests/scopes outside of this `fcontext()` will be treated as pending.
 - Note: This has the same function signature as `context()` for ease of use.

 - Parameter title: The `context`'s title that is included in the test output.
 - Parameter closure: The `context` scope to be executed during testing.
 */
public func fcontext(_ title: String, _ closure: () -> Void) {
    intakeScope(type: .context, title, closure, mark: .focused)
}

/**
 Adds a pending context scope.

 Context scopes are normally used to encompass a scenario that the subject under test or a specific behavior of the subject under test has to account for.

 - Warning: Tests within this `xcontext()` will be marked as pending regardless of any focus.
 - Note: This has the same function signature as `context()` for ease of use.

 - Parameter title: The `context`'s title that is included in the test output.
 - Parameter closure: The `context` scope to be executed during testing.
 */
public func xcontext(_ title: String, _ closure: () -> Void) {
    intakeScope(type: .context, title, closure, mark: .pending)
}

/**
 Adds a group scope.

 Normally all `beforeEach` scopes for a specific `it` scope are ran then all `afterEach` scopes after that specific `it` scope. The same is repeated for all subsequent `it` scopes. Group scopes, however, will run all `beforeEach` scopes then all encompassing `it` scopes then all `afterEach` scopes. This is to cut down on performace heavy test setups and teardowns.

 - Important: group scopes should generally only be used for performance purposes.

 - Parameter title: The `group`'s title that is included in the test output. Defaults to ""
 - Parameter closure: The `group` scope to be executed during testing. Only `expect().to()`s should be captured in this scope
 */
public func group(_ title: String = "", _ closure: () -> Void) {
    intakeScope(type: .group, title, closure, mark: .none)
}

/**
 Adds a group scope.

 Normally all `beforeEach` scopes for a specific `it` scope are ran then all `afterEach` scopes after that specific `it` scope. The same is repeated for all subsequent `it` scopes. Group scopes, however, will run all `beforeEach` scopes then all encompassing `it` scopes then all `afterEach` scopes. This is to cut down on performace heavy test setups and teardowns.

 - Important: group scopes should generally only be used for performance purposes.
 - Warning: If one or more focused tests/scopes are added, all non-focused tests/scopes outside of this `fgroup()` will be treated as pending.
 - Note: This has the same function signature as `group()` for ease of use.

 - Parameter title: The `group`'s title that is included in the test output. Defaults to ""
 - Parameter closure: The `group` scope to be executed during testing. Only `expect().to()`s should be captured in this scope
 */
public func fgroup(_ title: String = "", _ closure: () -> Void) {
    intakeScope(type: .group, title, closure, mark: .focused)
}

/**
 Adds a group scope.

 Normally all `beforeEach` scopes for a specific `it` scope are ran then all `afterEach` scopes after that specific `it` scope. The same is repeated for all subsequent `it` scopes. Group scopes, however, will run all `beforeEach` scopes then all encompassing `it` scopes then all `afterEach` scopes. This is to cut down on performace heavy test setups and teardowns.

 - Important: group scopes should generally only be used for performance purposes.
 - Warning: Tests within this `xgroup()` will be marked as pending regardless of any focus.
 - Note: This has the same function signature as `group()` for ease of use.

 - Parameter title: The `group`'s title that is included in the test output. Defaults to ""
 - Parameter closure: The `group` scope to be executed during testing. Only `expect().to()`s should be captured in this scope
 */
public func xgroup(_ title: String = "", _ closure: () -> Void) {
    intakeScope(type: .group, title, closure, mark: .pending)
}

/**
 Adds an it scope.

 It scopes are used to encompass expectations. It scopes will only report a passing test if all expectations pass validation.

 - Parameter title: The `it`'s title that is included in the test output.
 - Parameter closure: The `it` scope to be executed during testing. Only `expect().to()`s should be captured in this scope
 */
public func it(_ title: String, _ closure: @escaping () -> Void) {
    intakeIt(title, closure: closure, mark: .none)
}

/**
 Adds a focused it scope.

 It scopes are used to encompass expectations. It scopes will only report a passing test if all expectations pass validation.

 - Warning: If one or more focused tests/scopes are added, all non-focused tests/scopes outside of this `fit()` will be treated as pending.
 - Note: This has the same function signature as `it()` for ease of use.

 - Parameter title: The `it`'s title that is included in the test output.
 - Parameter closure: The `it` scope to be executed during testing. Only `expect().to()`s should be captured in this scope
 */
public func fit(_ title: String, _ closure: @escaping () -> Void) {
    intakeIt(title, closure: closure, mark: .focused)
}

/**
 Adds a pending it scope.

 It scopes are used to encompass expectations. It scopes will only report a passing test if all expectations pass validation.

 - Warning: Tests within this `xit()` will be marked as pending regardless of any focus.
 - Note: This has the same function signature as `xit()` for ease of use.

 - Parameter title: The `it`'s title that is included in the test output.
 - Parameter closure: The `it` scope to be executed during testing. Only `expect().to()`s should be captured in this scope
 */
public func xit(_ title: String, _ closure: @escaping () -> Void) {
    intakeIt(title, closure: closure, mark: .pending)
}

// MARK: - Steps

/**
 Adds a Before Each scope.

 Before Each scopes are used to setup tests.

 - Warning: Only one `beforeEach` is allowed per scope.
 - Note: `beforeEach`s are ran before each test in decending order of scope.

 - Parameter closure: The `beforeEach` scope to be executed during testing.
 */
public func beforeEach(_ closure: @escaping () -> Void) {
    intakeStep(type: .beforeEach, closure: closure)
}

/**
 Adds a Subject Action scope.

 Subject Action scopes are used to execute the behavior under test. These are used to ensure that subsequent tests do not test other behaviors.

 - Warning: Only one `subjectAction` is allowed per test.
 - Note: `subjectAction`s are ran after all `beforeEach`s regardless of scope level and before each test.

 - Parameter closure: The `subjectAction` scope to be executed during testing.
 */
public func subjectAction(_ closure: @escaping () -> Void) {
    intakeStep(type: .subjectAction, closure: closure)
}

/**
 Adds a After Each scope.

 After Each scopes are used to tear down tests.

 - Warning: Only one `afterEach` is allowed per scope.
 - Note: `afterEach`s are ran after each test in ascending order of scope.

 - Parameter closure: The `afterEach` scope to be executed during testing.
 */
public func afterEach(_ closure: @escaping () -> Void) {
    intakeStep(type: .afterEach, closure: closure)
}

// MARK: - Expect

/**
 Used to capture the actual value to be tested. Must call `to()`, `toNot()`, or `notTo()` function on the returned value of this function.

 - Parameter actual: The actual value to be tested.
 - Parameter line: The line the expect is on. Used to help locate failing tests. Defaults to #line. Should NOT change from the defaulted value.
 */
public func expect<A, E>(_ actual: A, line: Int = #line) -> ExpectPartOne<A, E> {
    return ExpectPartOne(actual: actual, line: line)
}

// MARK: - Private

private func intakeScope(type: ScopeType, _ title: String, _ closure: () -> Void, mark: Mark) {
    if let testScope = TestScope.currentTestScope {
        testScope.intake(Scope(type: type, title: title, mark: mark), closure: closure)
    } else {
        newTest(title: title, closure: closure, mark: mark)
    }
}

private func intakeStep(type: StepType, closure: @escaping () -> Void) {
    guard let currentScope = TestScope.currentTestScope else {
        fatalError(I18n.t(.stepOutsideOfScope(type)))
    }

    currentScope.intake(Step(type: type, closure))
}

private func intakeIt(_ title: String, closure: @escaping () -> Void, mark: Mark) {
    guard let currentScope = TestScope.currentTestScope else {
        fatalError(I18n.t(.itOutsideOfScope))
    }

    currentScope.intake(It(title: title, mark: mark, closure: closure))
}

private func newTest(title: String, closure: () -> Void, mark: Mark) {
    let testScope = TestScope(title: title, closure: closure, mark: mark)
    testScope.execute()
    TestScope.currentTestScope = nil
}
