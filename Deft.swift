
// TODO: fix bug where focus doesn't work if there are no `it`s in the scope
// TODO: should fatal error when `scope` is inside an `it`

private struct Constant {
    static let levelSpace = "   "
    static let emptyTitle = "" // "(no helpful text provided)"
    static let nilGroupKey = "_____"

    struct ErrorMessage {
        static let tooManySubjectActions = "only one \"subjectAction()\" per `it`"
    }

    struct OutPutPrefix {
        static let topLevel = "Test: "
        static let describe = "Describe: "
        static let context = "Context: "
        static let group = "Group: "
        static let it = "It: "
    }

    struct SingleCharacter {
        static let blank = " "
        static let success = "."
        static let failure = "F"
        static let pending = ">"
    }
}


private protocol TrackedScope {
    func add(_ step: Step)
    func add(_ it: It)
    func add(_ scope: Scope)
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

    init(description: String = "", total: Int = 0, succeeded: Int = 0, pending: Int = 0) {
        self.description = description
        self.total = total
        self.succeeded = succeeded
        self.pending = pending
    }

    static func + (lhs: TestResult, rhs: TestResult) -> TestResult {
        return TestResult(description: lhs.description + rhs.description,
                          total: lhs.total + rhs.total,
                          succeeded: lhs.succeeded + rhs.succeeded,
                          pending: lhs.pending + rhs.pending)
    }
}

private func format(_ string: String, level: Int, firstCharacter: String) -> String {
    let space = String(repeating: Constant.levelSpace, count: level)
    return firstCharacter + space + string + "\n"
}

private func endLine(totalCount: Int, succeeded: Int, pending: Int) -> String {
    let testText = totalCount == 1 ? "test" : "tests"
    return "\n Executed \(totalCount) \(testText)\n  |- \(succeeded) succeeded\n  |- \(totalCount - succeeded - pending) failed\n  |- \(pending) pending\n\n"
}


private class It {
    private let title: String
    private let closure: () -> Bool
    private let mark: Mark

    var underFocus: Bool = false
    var underPending: Bool = false

    var actingFocused: Bool {
        return mark == .focused || underFocus
    }

    var actingPending: Bool {
        return mark == .pending || underPending
    }

    var displayableTitle: String {
        get {
            return Constant.OutPutPrefix.it + (title.isEmpty ? Constant.emptyTitle : title)
        }
    }

    init(title: String, closure: @escaping () -> Bool, mark: Mark) {
        self.title = title
        self.closure = closure
        self.mark = mark
    }

    func process(underFocus: Bool, underPending: Bool) {
        self.underFocus = underFocus
        self.underPending = underPending
    }

    // MARK: Helper

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

    // MARK: Helper

    private static func executeGroup(_ its: [It], level: Int, steps: [Step], isSomethingFocused: Bool) -> TestResult {
        let hasTestsToRun = its.reduce(false) { $0 || $1.shouldExecute(isSomethingFocused: isSomethingFocused) }
        guard hasTestsToRun else {
            return its.reduce(TestResult()) {
                let testDescription = format($1.displayableTitle, level: level, firstCharacter: Constant.SingleCharacter.pending)
                return $0 + TestResult(description: testDescription, total: 1, pending: 1)
            }
        }

        let beforeEachs = steps.filter { $0.type == .beforeEach }
        let subjectActions = steps.filter { $0.type == .subjectAction }
        let afterEachs = steps.filter { $0.type == .afterEach }

        guard subjectActions.count <= 1 else {
            fatalError(Constant.ErrorMessage.tooManySubjectActions)
        }

        beforeEachs.forEach { $0.closure() }
        subjectActions.forEach { $0.closure() }

        let result = its.reduce(TestResult()) {
            guard $1.shouldExecute(isSomethingFocused: isSomethingFocused) else {
                let testDescription = format($1.displayableTitle, level: level, firstCharacter: Constant.SingleCharacter.pending)
                return $0 + TestResult(description: testDescription, total: 1, pending: 1)
            }

            let success = $1.closure()
            let outcomeSymbol = success ? Constant.SingleCharacter.success : Constant.SingleCharacter.failure
            let testDescription = format($1.displayableTitle, level: level, firstCharacter: outcomeSymbol)
            return $0 + TestResult(description: testDescription, total: 1, succeeded: success ? 1 : 0)
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
    private let type: ScopeType
    private let title: String
    private let mark: Mark

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
        let prefix: String
        switch type {
        case .topLevel: prefix = Constant.OutPutPrefix.topLevel
        case .describe: prefix = Constant.OutPutPrefix.describe
        case .context: prefix = Constant.OutPutPrefix.context
        case .group: prefix = Constant.OutPutPrefix.group
        }

        let displayableDescription = title.isEmpty ? Constant.emptyTitle : title

        return prefix + displayableDescription
    }

    var hasFocus: Bool {
        if actingPending {
            return false
        } else {
            let subScopeHasFocus = subScopes.reduce(false) { $0 || $1.hasFocus }
            let itHasFocus = its.reduce(false) { $0 || $1.actingFocused }
            return subScopeHasFocus || itHasFocus
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

    // MARK: static

    static func execute(_ scopes: [Scope], isSomethingFocused: Bool, level: Int = 0, accumulatedSteps: [Step] = []) -> TestResult {
        return scopes.reduce(TestResult()) {
            let aggregatedSteps = accumulatedSteps + $1.steps

            let scopeDescriptionResult = TestResult(description: format($1.displayableTitle, level: level, firstCharacter: Constant.SingleCharacter.blank))
            let itsResult = It.execute($1.its, level: level + 1, steps: aggregatedSteps, isSomethingFocused: isSomethingFocused, inGroup: $1.type == .group)
            let subScopesResult = execute($1.subScopes, isSomethingFocused: isSomethingFocused, level: level + 1, accumulatedSteps: aggregatedSteps)

            return $0 + scopeDescriptionResult + itsResult + subScopesResult
        }
    }
}


private class Tracker {
    var scopes: [TrackedScope]

    init(rootScope: TrackedScope) {
        self.scopes = [rootScope]
    }

    var currentScope: TrackedScope {
        return scopes.last!
    }

    func intake(_ step: Step) {
        scopes.last!.add(step)
    }

    func intake(_ it: It) {
        scopes.last!.add(it)
    }

    func intake(_ scope: Scope, closure: () -> Void) {
        scopes.last!.add(scope)
        scopes.append(scope)
        closure()
        scopes.removeLast()
    }
}

private class TestScope: TrackedScope {
    static var currentTestScope: TestScope?

    private let tracker: Tracker
    private let rootScope: Scope

    init(title: String, closure: () -> Void, mark: Mark) {
        rootScope = Scope(type: .topLevel, title: title, mark: mark)
        self.tracker = Tracker(rootScope: rootScope)

        TestScope.currentTestScope = self

        closure()
    }

    func intake(_ scope: Scope, closure: () -> Void) {
        tracker.intake(scope, closure: closure)
    }

    func intake(_ step: Step) {
        tracker.intake(step)
    }

    func intake(_ it: It) {
        tracker.intake(it)
    }

    func execute() {
        rootScope.process(underFocus: false, underPending: false)
        let result = Scope.execute([rootScope], isSomethingFocused: rootScope.hasFocus)
        let endline = endLine(totalCount: result.total, succeeded: result.succeeded, pending: result.pending)
        print(result.description + endline)
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


// MARK: Scopes

func describe(_ title: String, _ closure: () -> Void) {
    intakeScope(type: .describe, title, closure, mark: .none)
}

func fdescribe(_ title: String, _ closure: () -> Void) {
    intakeScope(type: .describe, title, closure, mark: .focused)
}

func xdescribe(_ title: String, _ closure: () -> Void) {
    intakeScope(type: .describe, title, closure, mark: .pending)
}

func context(_ title: String, _ closure: () -> Void) {
    intakeScope(type: .context, title, closure, mark: .none)
}

func fcontext(_ title: String, _ closure: () -> Void) {
    intakeScope(type: .context, title, closure, mark: .focused)
}

func xcontext(_ title: String, _ closure: () -> Void) {
    intakeScope(type: .context, title, closure, mark: .pending)
}

func group(_ title: String = "", _ closure: () -> Void) {
    intakeScope(type: .group, title, closure, mark: .none)
}

func fgroup(_ title: String = "", _ closure: () -> Void) {
    intakeScope(type: .group, title, closure, mark: .focused)
}

func xgroup(_ title: String = "", _ closure: () -> Void) {
    intakeScope(type: .group, title, closure, mark: .pending)
}

// MARK: Steps

func beforeEach(_ closure: @escaping () -> Void) {
    intakeStep(type: .beforeEach, closure: closure)
}

func subjectAction(_ closure: @escaping () -> Void) {
    intakeStep(type: .subjectAction, closure: closure)
}

func afterEach(_ closure: @escaping () -> Void) {
    intakeStep(type: .afterEach, closure: closure)
}

// MARK: Its

func it(_ title: String, closure: @escaping () -> Bool) {
    intakeIt(title, closure: closure, mark: .none)
}

func fit(_ title: String, closure: @escaping () -> Bool) {
    intakeIt(title, closure: closure, mark: .focused)
}

func xit(_ title: String, closure: @escaping () -> Bool) {
    intakeIt(title, closure: closure, mark: .pending)
}

// Helpers

private func intakeScope(type: ScopeType, _ title: String, _ closure: () -> Void, mark: Mark) {
    if let testScope = TestScope.currentTestScope {
        testScope.intake(Scope(type: type, title: title, mark: mark), closure: closure)
    } else {
        newTest(title: title, closure: closure, mark: mark)
    }
}

private func intakeStep(type: StepType, closure: @escaping () -> Void) {
    guard let currentScope = TestScope.currentTestScope else {
        fatalError("`\(type)`s must be inside a `describe` or `context` scope.")
    }

    currentScope.intake(Step(type: type, closure))
}

private func intakeIt(_ title: String, closure: @escaping () -> Bool, mark: Mark) {
    guard let currentScope = TestScope.currentTestScope else {
        fatalError("`it`s must be inside a `describe` or `context` scope.")
    }

    currentScope.intake(It(title: title, closure: closure, mark: mark))
}

private func newTest(title: String, closure: () -> Void, mark: Mark) {
    let testScope = TestScope(title: title, closure: closure, mark: mark)
    testScope.execute()
    TestScope.currentTestScope = nil
}


















describe("a class") {
    context("when stuff happens") {
        describe("the shape of the stuff") {
            subjectAction {

            }
        }

        context("when that stuff is brown") {
            beforeEach {

            }

            beforeEach {
                print("before each")
            }

            afterEach {
                print("after each\n")
            }

            group("abc") {
                it("should 1") {
                    print("should 1")
                    return "" == "asdf"
                }

                it("should 2") {
                    print("should 2")
                    return true
                }

                it("should 3") {
                    print("should 3")
                    return true
                }
            }
            
            it("should 4") {
                print("should 4")
                return false
            }
        }
        
        context("when that stuff is gray") {
            it("") {
                return true
            }
        }
    }
}


context("next thing") {
    xdescribe("next thing to check") {
        
    }
}



























print("\n  ** EOF **")
