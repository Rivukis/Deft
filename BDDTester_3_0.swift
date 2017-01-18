fileprivate struct Constant {
    static let levelSpace = "   "
    static let emptyDescription = "" // "(no helpful text provided)"
    
    struct ErrorMessage {
        static let tooManyBeforeEachs = "only one \"beforeEach()\" per scope"
        static let tooManySubjectActions = "only one \"subjectAction()\" per test"
        static let tooManyAfterEachs = "only one \"afterEach()\" per scope"
    }
    
    struct OutPutPrefix {
        static let describe = "Describe: "
        static let context = "Context: "
        static let it = "It: "
    }
    
    struct SingleCharacter {
        static let blank = " "
        static let success = "."
        static let failure = "F"
        static let pending = ">"
    }
}

/**
 Initializes a testing scope, executes the tests, and prints out the results to the console window.
 
 - Important: This function is required when writing tests. Do NOT call this function inside of a test scope.
 - Note: The default shortcut for showing/hiding the console window is `⌘⇧Y`
 
 ## Output Notation
 **"."** : Test succeeded
 
 **"F"** : Test failed
 
 **">"** : Test marked as pending
 
 - Parameter subjectDescription: This is the description of the thing you are testing.
 - Parameter body: The `describe` scope to be executed during testing. The `RIVScope` parameter is used for adding new `describe`s, `context`s, `it`s, `beforeEach`s, `afterEach`s, and/or a `subjectAction`.
 */
func test(_ subjectDescription: String, _ body: @escaping (BDDScope) -> Void) {
    let scope = BDDScope(type: .describe, description: subjectDescription, body: body, focused: false, pending: false)
    execute(scope: scope, body: body)
}

/**
 Initializes a testing scope, executes the tests, and prints out the results to the console window.
 
 - Important: This function is required when writing tests. Do NOT call this function inside of a test scope.
 - Note: The default shortcut for showing/hiding the console window is `⌘⇧Y`
 - Note: This has the same function signature as its counterpart for ease of use.
 
 ## Output Notation
 **"."** : Test succeeded
 
 **"F"** : Test failed
 
 **">"** : Test marked as pending
 
 - Parameter subjectDescription: This is the description of the thing you are testing.
 - Parameter body: The `describe` scope to be executed during testing. The `RIVScope` parameter is used for adding new `describe`s, `context`s, `it`s, `beforeEach`s, `afterEach`s, and/or a `subjectAction`.
 
 */
func xtest(_ subjectDescription: String, _ body: @escaping (BDDScope) -> Void) {
    let scope = BDDScope(type: .describe, description: subjectDescription, body: body, focused: false, pending: true)
    execute(scope: scope, body: body)
}

/**
 Adds a Before Each scope.
 
 - Important: Only call this funciton inside a test scope whose closure provides a `RIVScope`.
 - Warning: Only one `beforeEach` is allowed per scope.
 - Note: `beforeEach`s are ran before each test in decending order of scope.
 
 - Parameter scope: Pass in the `RIVScope` that is provided by the enclosing test scope.
 - Parameter body: The `beforeEach` scope to be executed during testing.
 */
func beforeEach(_ scope: BDDScope, _ body: @escaping () -> Void) {
    guard scope.beforeEach == nil else {
        fatalError(Constant.ErrorMessage.tooManyBeforeEachs)
    }
    
    scope.beforeEach = body
}

/**
 Adds a Subject Action scope.
 
 - Important: Only call this funciton inside a test scope whose closure provides a `RIVScope`.
 - Warning: Only one `subjectAction` is allowed per test.
 - Note: The `subjectAction` is ran before each test, but AFTER ALL `beforeEach`s regardless of the `beforeEach`s' or `subjectAction`'s scopes.
 
 - Parameter scope: Pass in the `RIVScope` that is provided by the enclosing test scope.
 - Parameter body: The `subjectAction` scope to be executed during testing.
 */
func subjectAction(_ scope: BDDScope, _ body: @escaping () -> Void) {
    guard scope.subjectAction == nil else {
        fatalError(Constant.ErrorMessage.tooManySubjectActions)
    }
    
    scope.subjectAction = body
}

/**
 Adds an After Each scope.
 
 - Important: Only call this funciton inside a test scope whose closure provides a `RIVScope`.
 - Warning: Only one `afterEach` is allowed per scope.
 - Note: `afterEach`s are ran after each test in ascending order of scope.
 
 - Parameter scope: Pass in the `RIVScope` that is provided by the enclosing test scope.
 - Parameter body: The `afterEach` scope to be executed during testing.
 */
func afterEach(_ scope: BDDScope, _ body: @escaping () -> Void) {
    guard scope.afterEach == nil else {
        fatalError(Constant.ErrorMessage.tooManyAfterEachs)
    }
    
    scope.afterEach = body
}

/**
 Adds a describe scope.
 
 - Important: Only call this funciton inside a test scope whose closure provides a `RIVScope`.
 
 - Parameter description: The `describe`'s description that is included in the test output.
 - Parameter scope: Pass in the `RIVScope` that is provided by the enclosing test scope.
 - Parameter body: The `describe` scope to be executed during testing. The `RIVScope` parameter is used for adding new `describe`s, `context`s, `it`s, `beforeEach`s, `afterEach`s, and/or a `subjectAction`.
 */
func describe(_ description: String, _ scope: BDDScope, _ body:  @escaping (BDDScope) -> Void) {
    scope.subScopes.append(BDDScope(type: .describe, description: description, body: body, focused: false, pending: false))
}

/**
 Adds a focused describe.
 
 - Important: Only call this funciton inside a test scope whose closure provides a `RIVScope`.
 - Warning: If one or more focused tests/scopes are added, all non-focused tests/scopes outside of this `fdescribe` will be treated as pending.
 - Note: This has the same function signature as its counterparts for ease of use.
 
 - Parameter description: The `describe`'s description that is included in the test output.
 - Parameter scope: Pass in the `RIVScope` that is provided by the enclosing test scope.
 - Parameter body: The `describe` scope to be executed during testing. The `RIVScope` parameter is used for adding new `describe`s, `context`s, `it`s, `beforeEach`s, `afterEach`s, and/or a `subjectAction`.
 */
func fdescribe(_ description: String, _ scope: BDDScope, _ body:  @escaping (BDDScope) -> Void) {
    scope.subScopes.append(BDDScope(type: .describe, description: description, body: body, focused: true, pending: false))
}

/**
 Adds a pending describe.
 
 - Important: Only call this funciton inside a test scope whose closure provides a `RIVScope`.
 - Warning: Tests within this `xdescribe` will be marked as pending regardless of any focus.
 - Note: This has the same function signature as its counterparts for ease of use.
 
 - Parameter description: The `describe`'s description that is included in the test output.
 - Parameter scope: Pass in the `RIVScope` that is provided by the enclosing test scope.
 - Parameter body: The `describe` scope to be executed during testing. The `RIVScope` parameter is used for adding new `describe`s, `context`s, `it`s, `beforeEach`s, `afterEach`s, and/or a `subjectAction`.
 */
func xdescribe(_ description: String, _ scope: BDDScope, _ body:  @escaping (BDDScope) -> Void) {
    scope.subScopes.append(BDDScope(type: .describe, description: description, body: body, focused: false, pending: true))
}

/**
 Adds a context scope.
 
 - Important: Only call this funciton inside a test scope whose closure provides a `RIVScope`.
 
 - Parameter description: The `context`'s description that is included in the test output.
 - Parameter scope: Pass in the `RIVScope` that is provided by the enclosing test scope.
 - Parameter body: The `context` scope to be executed during testing. The `RIVScope` parameter is used for adding new `describe`s, `context`s, `it`s, `beforeEach`s, `afterEach`s, and/or a `subjectAction`.
 */
func context(_ description: String, _ scope: BDDScope, _ body:  @escaping (BDDScope) -> Void) {
    scope.subScopes.append(BDDScope(type: .context, description: description, body: body, focused: false, pending: false))
}

/**
 Adds a focused context.
 
 - Important: Only call this funciton inside a test scope whose closure provides a `RIVScope`.
 - Warning: If one or more focused tests/scopes are added, all non-focused tests/scopes outside of this `fcontext` will be treated as pending.
 - Note: This has the same function signature as its counterparts for ease of use.
 
 - Parameter description: The `context`'s description that is included in the test output.
 - Parameter scope: Pass in the `RIVScope` that is provided by the enclosing test scope.
 - Parameter body: The `context` scope to be executed during testing. The `RIVScope` parameter is used for adding new `describe`s, `context`s, `it`s, `beforeEach`s, `afterEach`s, and/or a `subjectAction`.
 */
func fcontext(_ description: String, _ scope: BDDScope, _ body:  @escaping (BDDScope) -> Void) {
    scope.subScopes.append(BDDScope(type: .context,
                                    description: description,
                                    body: body,
                                    focused: true,
                                    pending: false))
}

/**
 Adds a pending context.
 
 - Important: Only call this funciton inside a test scope whose closure provides a `RIVScope`.
 - Warning: Tests within this `xcontext` will be marked as pending regardless of any focus.
 - Note: This has the same function signature as its counterparts for ease of use.
 
 - Parameter description: The `context`'s description that is included in the test output.
 - Parameter scope: Pass in the `RIVScope` that is provided by the enclosing test scope.
 - Parameter body: The `context` scope to be executed during testing. The `RIVScope` parameter is used for adding new `describe`s, `context`s, `it`s, `beforeEach`s, `afterEach`s, and/or a `subjectAction`.
 */
func xcontext(_ description: String, _ scope: BDDScope, _ body:  @escaping (BDDScope) -> Void) {
    scope.subScopes.append(BDDScope(type: .context,
                                    description: description,
                                    body: body,
                                    focused: false,
                                    pending: true))}

/**
 Adds a test.
 
 - Important: Only call this funciton inside a test scope whose closure provides a `RIVScope`.
 
 - Parameter description: The `it`'s description that is included in the test output.
 - Parameter scope: Pass in the `RIVScope` that is provided by the enclosing test scope.
 - Parameter body: The `it` scope to be executed during testing. The boolean return value is the determination for a passing or failing test (true for success, false for failure).
 */
func it(_ description: String, _ scope: BDDScope, _ body:  @escaping () -> Bool) {
    scope.its.append(BDDIt(description: description,
                           body: body,
                           focused: false,
                           pending: false))
}

/**
 Adds a focused test.
 
 - Important: Only call this funciton inside a test scope whose closure provides a `RIVScope`.
 - Warning: If one or more focused tests/scopes are added, all non-focused tests/scopes outside of this `fit` will be treated as pending.
 - Note: This has the same function signature as its counterparts for ease of use.
 
 - Parameter description: The `it`'s description that is included in the test output.
 - Parameter scope: Pass in the `RIVScope` that is provided by the enclosing test scope.
 - Parameter body: The `it` scope to be executed during testing. The boolean return value is the determination for a passing or failing test (true for success, false for failure).
 */
func fit(_ description: String, _ scope: BDDScope, _ body:  @escaping () -> Bool) {
    scope.its.append(BDDIt(description: description,
                           body: body,
                           focused: true,
                           pending: false))
}

/**
 Adds a pending test.
 
 - Important: Only call this funciton inside a test scope whose closure provides a `RIVScope`.
 - Warning: Pending tests will not be executed regardless of any focus.
 - Note: This has the same function signature as its counterparts for ease of use.
 
 - Parameter description: The `it`'s description that is included in the test output.
 - Parameter scope: Pass in the `RIVScope` that is provided by the enclosing test scope.
 - Parameter body: The `it` scope to be executed during testing. The boolean return value is the determination for a passing or failing test (true for success, false for failure).
 */
func xit(_ description: String, _ scope: BDDScope, _ body:  @escaping () -> Bool) {
    scope.its.append(BDDIt(description: description,
                           body: body,
                           focused: false,
                           pending: true))
}

/**
 Do NOT use this class directly. An instance of this class will be passed into a test scope's body. Use that instance when adding more test elements.
 */
public class BDDScope {
    private let type: BDDScopeType
    private let _description: String
    private let body: (_ scope: BDDScope) -> Void
    fileprivate var focused: Bool
    fileprivate var pending: Bool
    
    fileprivate var beforeEach: (() -> Void)?
    fileprivate var subjectAction: (() -> Void)?
    fileprivate var its: [BDDIt] = []
    fileprivate var subScopes: [BDDScope] = []
    fileprivate var afterEach: (() -> Void)?
    
    fileprivate var description: String {
        get {
            let prefix = type == .describe ? Constant.OutPutPrefix.describe : Constant.OutPutPrefix.context
            let displayableDescription = _description.isEmpty ? Constant.emptyDescription : _description
            
            return prefix + displayableDescription
        }
    }
    
    fileprivate init(type: BDDScopeType, description: String, body: @escaping (BDDScope) -> Void, focused: Bool, pending: Bool) {
        self.type = type
        self._description = description
        self.body = body
        self.focused = focused
        self.pending = pending
    }
    
    fileprivate func process(underFocus: Bool, underPending: Bool) -> Bool {
        focused = focused || underFocus
        pending = pending || underPending
        
        body(self)
        markSubScopes(underFocus: focused, underPending: pending)
        let anItWasFocused = isAnItFocused()
        markIts(underFocus: focused, underPending: pending)
        
        if pending {
            return false
        }
        
        return focused || anItWasFocused
    }
    
    fileprivate func markSubScopes(underFocus: Bool, underPending: Bool) {
        for scope in subScopes {
            if underFocus { scope.focused = true }
            if underPending { scope.pending = true }
        }
    }
    
    fileprivate func markIts(underFocus: Bool, underPending: Bool) {
        its.forEach { it in
            if underFocus { it.focused = true }
            if underPending { it.pending = true }
        }
    }
    
    fileprivate func isAnItFocused() -> Bool {
        for it in its {
            if it.focused {
                return true
            }
        }
        
        return false
    }
    
    fileprivate static func process(scopes: [BDDScope], underFocus: Bool = false, underPending: Bool = false) -> Bool {
        var isSomethingFocused = false
        for scope in scopes {
            let scopeHasFocus = scope.process(underFocus: underFocus, underPending: underPending)
            let aSubScopesHasFocus = process(scopes: scope.subScopes, underFocus: scope.focused, underPending: scope.pending)
            
            isSomethingFocused = isSomethingFocused || scopeHasFocus || aSubScopesHasFocus
        }
        
        return isSomethingFocused
    }
    
    fileprivate static func execute(_ scopes: [BDDScope], isSomethingFocused: Bool, level: Int = 0, beforeEachs: [() -> Void] = [], afterEachs: [() -> Void] = [], subjectAction: (() -> Void)? = nil) -> TestResult {
        var result = TestResult()
        
        scopes.forEach { scope in
            guard subjectAction == nil || scope.subjectAction == nil else {
                fatalError(Constant.ErrorMessage.tooManySubjectActions)
            }
            
            var beforeEachs = beforeEachs
            var afterEachs = afterEachs
            var subjectAction = subjectAction
            
            if let beforeEach = scope.beforeEach {
                beforeEachs.append(beforeEach)
            }
            
            subjectAction = scope.subjectAction ?? subjectAction
            
            if let afterEach = scope.afterEach {
                afterEachs.append(afterEach)
            }
            
            let scopeDescriptionResult = TestResult(description: format(scope.description, level: level, firstCharacter: Constant.SingleCharacter.blank))
            let itsResult = BDDIt.execute(scope.its, level: level + 1, beforeEachs: beforeEachs, afterEachs: afterEachs, subjectAction: subjectAction, isSomethingFocused: isSomethingFocused)
            let subScopesResult = execute(scope.subScopes, isSomethingFocused: isSomethingFocused, level: level + 1, beforeEachs: beforeEachs, afterEachs: afterEachs, subjectAction: subjectAction)
            
            result = result.resultByCombining(with: scopeDescriptionResult).resultByCombining(with: itsResult).resultByCombining(with: subScopesResult)
        }
        
        return result
    }
}

private enum BDDScopeType {
    case describe
    case context
}

private class BDDIt {
    private let _description: String
    private let body: () -> Bool
    var focused: Bool
    var pending: Bool
    
    var description: String {
        get {
            return Constant.OutPutPrefix.it + (_description.isEmpty ? Constant.emptyDescription : _description)
        }
    }
    
    init(description: String, body: @escaping () -> Bool, focused: Bool, pending: Bool) {
        self._description = description
        self.body = body
        self.focused = focused
        self.pending = pending
    }
    
    func shouldExecute(isSomethingFocused: Bool) -> Bool {
        if pending {
            return false
        }
        if isSomethingFocused {
            return focused
        }
        
        return true
    }
    
    func execute(beforeEachs: [() -> Void], subjectAction: (() -> Void)?, afterEachs: [() -> Void], level: Int, isSomethingFocused: Bool) -> TestResult {
        guard shouldExecute(isSomethingFocused: isSomethingFocused) else {
            let testDescription = format(description, level: level, firstCharacter: Constant.SingleCharacter.pending)
            return TestResult(description: testDescription, total: 1, pending: 1)
        }
        
        beforeEachs.forEach { $0() }
        subjectAction?()
        let success = body()
        afterEachs.reversed().forEach { $0() }
        
        let outcomeSymbol = success ? Constant.SingleCharacter.success : Constant.SingleCharacter.failure
        let testDescription = format(description, level: level, firstCharacter: outcomeSymbol)
        return TestResult(description: testDescription, total: 1, succeeded: success ? 1 : 0)
    }
    
    static func execute(_ its: [BDDIt], level: Int, beforeEachs: [() -> Void], afterEachs: [() -> Void], subjectAction: (() -> Void)?, isSomethingFocused: Bool) -> TestResult {
        return its.reduce(TestResult()) { result, it in
            let output = it.execute(beforeEachs: beforeEachs,
                                    subjectAction: subjectAction,
                                    afterEachs: afterEachs,
                                    level: level,
                                    isSomethingFocused: isSomethingFocused)
            return result.resultByCombining(with: output)
        }
    }
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
    
    func resultByCombining(with other: TestResult) -> TestResult {
        return TestResult(description: description + other.description,
                          total: total + other.total,
                          succeeded: succeeded + other.succeeded,
                          pending: pending + other.pending)
    }
}

private func execute(scope: BDDScope, body: @escaping (BDDScope) -> Void) {
    let isSomethingFocused = BDDScope.process(scopes: [scope])
    let result = BDDScope.execute([scope], isSomethingFocused: isSomethingFocused)
    let endline = endLine(totalCount: result.total, succeeded: result.succeeded, pending: result.pending)
    
    print(result.description + endline)
}

private func endLine(totalCount: Int, succeeded: Int, pending: Int) -> String {
    let testText = totalCount == 1 ? "test" : "tests"
    return "\n Executed \(totalCount) \(testText)\n |- \(succeeded) succeeded\n |- \(totalCount - succeeded - pending) failed\n |- \(pending) pending"
}

private func format(_ string: String, level: Int, firstCharacter: String) -> String {
    let space = String(repeating: Constant.levelSpace, count: level)
    return firstCharacter + space + string + "\n"
}
