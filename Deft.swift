
// MARK: - Matcher Framework

public protocol Matcher {
    associatedtype Actual
    associatedtype Expected

    func execute(actual: Actual) -> Bool
}

private class _AnyMatcherBoxInterface<A, E>: Matcher {
    public typealias Actual = A
    public typealias Expected = E

    func execute(actual: Actual) -> Bool {
        fatalError("abstract class")
    }
}

private class _AnyMatcherBox<T: Matcher>: _AnyMatcherBoxInterface<T.Actual, T.Expected> {
    let concrete: T

    init(concrete: T) {
        self.concrete = concrete
    }

    override func execute(actual: T.Actual) -> Bool {
        return concrete.execute(actual: actual)
    }
}

public class AnyMatcher<A, E>: Matcher {
    public typealias Actual = A
    public typealias Expected = E

    private let box: _AnyMatcherBoxInterface<Actual, Expected>

    init<T: Matcher>(matcher: T) where T.Actual == A, T.Expected == E {
        self.box = _AnyMatcherBox(concrete: matcher)
    }

    public func execute(actual: A) -> Bool {
        return box.execute(actual: actual)
    }
}

// MARK: - Default Matchers

public struct Closure<R> {
    let closure: () -> R

    public init(_ closure: @escaping () -> R) {
        self.closure = closure
    }

    func execute() -> R {
        return closure()
    }
}

public struct ThrowingClosure<R> {
    let closure: () throws -> R

    public init(_ closure: @escaping () throws -> R) {
        self.closure = closure
    }

    func execute() throws -> R {
        return try closure()
    }
}

class EqualMatcher<T: Equatable>: Matcher {
    public typealias Actual = T?
    public typealias Expected = T

    let expected: Expected

    init(expected: Expected) {
        self.expected = expected
    }

    public func execute(actual: Actual) -> Bool {
        return actual == expected
    }
}

public protocol BoolType {
    var toBool: Bool { get }
}
extension BoolType {
    public var toBool: Bool { return self as! Bool }
}
extension Bool: BoolType {}

class BeTrueMatcher<T: BoolType>: Matcher {
    typealias Actual = T
    typealias Expected = Void

    func execute(actual: T) -> Bool {
        return actual.toBool
    }
}

class BeFalseMatcher<T: BoolType>: Matcher {
    typealias Actual = T
    typealias Expected = Void

    func execute(actual: T) -> Bool {
        return !actual.toBool
    }
}

public protocol OptionalType {
    associatedtype WrappedType
    var toOptional: WrappedType? { get }
}
extension OptionalType {
    public var toOptional: WrappedType? { return self as? WrappedType }
}
extension Optional: OptionalType {
    public typealias WrappedType = Wrapped
}

class BeNilMatcher<T: OptionalType>: Matcher {
    public typealias Actual = T
    public typealias Expected = Void

    public func execute(actual: Actual) -> Bool {
        return actual.toOptional == nil
    }
}

class BeMatcher<T: AnyObject>: Matcher {
    public typealias Actual = T
    public typealias Expected = T

    let expected: Expected

    init(expected: Expected) {
        self.expected = expected
    }

    func execute(actual: Actual) -> Bool {
        return actual === expected
    }
}

public protocol DoubleConvertable {
    var toDouble: Double { get }
}
extension Double: DoubleConvertable {
    public var toDouble: Double { return Double(self) }
}
extension Float: DoubleConvertable {
    public var toDouble: Double { return Double(self) }
}
class BeCloseToMatcher<T: DoubleConvertable>: Matcher {
    public typealias Actual = T
    public typealias Expected = T

    let expected: Expected
    let maxDelta: Double

    init(expected: Expected, maxDelta: Double) {
        self.expected = expected
        self.maxDelta = maxDelta
    }

    func execute(actual: Actual) -> Bool {
        return abs(actual.toDouble - expected.toDouble) <= maxDelta
    }
}

class PassComparisonMatcher<T: Comparable>: Matcher {
    public typealias Actual = T
    public typealias Expected = T

    let expected: Expected
    let operation: (T, T) -> Bool

    init(operation: @escaping (T, T) -> Bool, expected: Expected) {
        self.expected = expected
        self.operation = operation
    }

    func execute(actual: Actual) -> Bool {
        return operation(actual, expected)
    }
}

class HaveCountMatcher<C: Collection, IdxDist>: Matcher where C.IndexDistance == IdxDist {
    public typealias Actual = C
    public typealias Expected = IdxDist

    let expected: Expected

    init(expected: Expected) {
        self.expected = expected
    }

    public func execute(actual: Actual) -> Bool {
        return actual.count == expected
    }
}

class ThrowErrorMatcher: Matcher {
    public typealias Actual = ThrowingClosure<Void>
    public typealias Expected = Void

    let errorVerifier: ((Error) -> Bool)?

    init(errorVerifier: ((Error) -> Bool)?) {
        self.errorVerifier = errorVerifier
    }

    func execute(actual: Actual) -> Bool {
        do {
            try actual.execute()
        } catch let error {
            if let errorVerifier = errorVerifier {
                return errorVerifier(error)
            }

            return true
        }

        return false
    }
}

class ThrowEquatableErrorMatcher<T: Error & Equatable>: Matcher {
    public typealias Actual = ThrowingClosure<Void>
    public typealias Expected = T

    let expectedError: Expected

    init(expectedError: Expected) {
        self.expectedError = expectedError
    }

    func execute(actual: Actual) -> Bool {
        do {
            try actual.execute()
        } catch let error {
            if let error = error as? T {
                return error == expectedError
            }

            return false
        }

        return false
    }
}

class SucceedMatcher: Matcher {
    public typealias Actual = Closure<Bool>
    public typealias Expected = Void

    func execute(actual: Actual) -> Bool {
        return actual.execute()
    }
}

class LogTrackerMatcher: Matcher {
    public typealias Actual = Closure<Void>
    public typealias Expected = Void

    func execute(actual: Actual) -> Bool {
        actual.execute()
        return true
    }
}

// MARK: - Public Matcher Functions

public func equal<T: Equatable>(_ expected: T) -> AnyMatcher<T?, T> {
    return AnyMatcher(matcher: EqualMatcher(expected: expected))
}

public func beTrue<T: BoolType>() -> AnyMatcher<T, Void> {
    return AnyMatcher(matcher: BeTrueMatcher())
}

public func beFalse<T: BoolType>() -> AnyMatcher<T, Void> {
    return AnyMatcher(matcher: BeFalseMatcher())
}

public func beNil<T: OptionalType>() -> AnyMatcher<T, Void> {
    return AnyMatcher(matcher: BeNilMatcher())
}

public func be<T: AnyObject>(_ expected: T) -> AnyMatcher<T, T> {
    return AnyMatcher(matcher: BeMatcher(expected: expected))
}

public func beCloseTo<T: DoubleConvertable>(_ expected: T, maxDelta: Double = 0.0001) -> AnyMatcher<T, T> {
    return AnyMatcher(matcher: BeCloseToMatcher(expected: expected, maxDelta: maxDelta))
}

public func passComparison<T: Comparable>(_ operation: @escaping (T, T) -> Bool, _ expected: T) -> AnyMatcher<T, T> {
    return AnyMatcher(matcher: PassComparisonMatcher(operation: operation, expected: expected))
}

public func haveCount<C: Collection, IdxDist>(_ expected: IdxDist) -> AnyMatcher<C, IdxDist> where C.IndexDistance == IdxDist {
    return AnyMatcher(matcher: HaveCountMatcher(expected: expected))
}

public func throwError(errorVerifier: ((Error) -> Bool)? = nil) -> AnyMatcher<ThrowingClosure<Void>, Void> {
    return AnyMatcher(matcher: ThrowErrorMatcher(errorVerifier: errorVerifier))
}

public func throwError<T: Error & Equatable>(error: T) -> AnyMatcher<ThrowingClosure<Void>, T> {
    return AnyMatcher(matcher: ThrowEquatableErrorMatcher(expectedError: error))
}

public func succeed() -> AnyMatcher<Closure<Bool>, Void> {
    return AnyMatcher(matcher: SucceedMatcher())
}

public func log() -> AnyMatcher<Closure<Void>, Void> {
    return AnyMatcher(matcher: LogTrackerMatcher())
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

    init<A, E>(actual: A, matcher: AnyMatcher<A, E>, line: Int, negativeTest: Bool) {
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

public class ExpectPartOne<A, E> {
    let actual: A
    let line: Int

    init(actual: A, line: Int) {
        self.actual = actual
        self.line = line
    }

    public func to(_ matcher: AnyMatcher<A, E>) {
        guard let currentScope = TestScope.currentTestScope else {
            fatalError(I18n.t(.expectOutsideOfIt))
        }

        let expect = Expect(actual: actual, matcher: matcher, line: line, negativeTest: false)
        currentScope.intake(expect)
    }

    public func toNot(_ matcher: AnyMatcher<A, E>) {
        guard let currentScope = TestScope.currentTestScope else {
            fatalError(I18n.t(.expectOutsideOfIt))
        }

        let expect = Expect(actual: actual, matcher: matcher, line: line, negativeTest: true)
        currentScope.intake(expect)
    }

    public func notTo(_ matcher: AnyMatcher<A, E>) {
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

public func describe(_ title: String, _ closure: () -> Void) {
    intakeScope(type: .describe, title, closure, mark: .none)
}

public func fdescribe(_ title: String, _ closure: () -> Void) {
    intakeScope(type: .describe, title, closure, mark: .focused)
}

public func xdescribe(_ title: String, _ closure: () -> Void) {
    intakeScope(type: .describe, title, closure, mark: .pending)
}

public func context(_ title: String, _ closure: () -> Void) {
    intakeScope(type: .context, title, closure, mark: .none)
}

public func fcontext(_ title: String, _ closure: () -> Void) {
    intakeScope(type: .context, title, closure, mark: .focused)
}

public func xcontext(_ title: String, _ closure: () -> Void) {
    intakeScope(type: .context, title, closure, mark: .pending)
}

public func group(_ title: String = "", _ closure: () -> Void) {
    intakeScope(type: .group, title, closure, mark: .none)
}

public func fgroup(_ title: String = "", _ closure: () -> Void) {
    intakeScope(type: .group, title, closure, mark: .focused)
}

public func xgroup(_ title: String = "", _ closure: () -> Void) {
    intakeScope(type: .group, title, closure, mark: .pending)
}

public func it(_ title: String, _ closure: @escaping () -> Void) {
    intakeIt(title, closure: closure, mark: .none)
}

public func fit(_ title: String, _ closure: @escaping () -> Void) {
    intakeIt(title, closure: closure, mark: .focused)
}

public func xit(_ title: String, _ closure: @escaping () -> Void) {
    intakeIt(title, closure: closure, mark: .pending)
}

// MARK: - Steps

public func beforeEach(_ closure: @escaping () -> Void) {
    intakeStep(type: .beforeEach, closure: closure)
}

public func subjectAction(_ closure: @escaping () -> Void) {
    intakeStep(type: .subjectAction, closure: closure)
}

public func afterEach(_ closure: @escaping () -> Void) {
    intakeStep(type: .afterEach, closure: closure)
}

// MARK: - Expect

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
