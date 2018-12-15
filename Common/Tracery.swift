//
//  Tracery.swift
//  
//
//  Created by Benzi on 10/03/17
//	Modified by martipi on 26/10/18
//
//

import Foundation

struct RuleMapping {
    let candidates: [RuleCandidate]
    var selector: RuleCandidateSelector
}

struct RuleCandidate {
    let text: String
    var value: ValueCandidate
}


@objc public class TraceryOptions : NSObject {
    public var tagStorageType = TaggingPolicy.unilevel
    @objc public var isRuleAnalysisEnabled = true
	@objc public var useStandardModifiers = true
	@objc public var isDeterministic = false
	@objc public var seed = 0
}

extension TraceryOptions {
    public static let defaultSet = TraceryOptions()
}

@objc public class Tracery : NSObject {
    
    var objects = [String: Any]()
    var ruleSet: [String: RuleMapping] = [:]
    var runTimeRuleSet = [String: RuleMapping]()
    var mods: [String: (String,[String])->String] = [:]
    var tagStorage: TagStorage
    var contextStack: ContextStack
	var randomSource_: RandomSource = FallbackRandomSource.shared
	var regex = RegularExpressions()
	
	// wonky workaround for getting readonly access to randomSource
	public var randomSource: RandomSource {
		return randomSource_
	}
    public var ruleNames: [String] { return ruleSet.keys.map { $0 } }
	public var modifierNames: [String] { return mods.keys.map { $0 } }

    convenience public init(_ options: TraceryOptions = TraceryOptions.defaultSet) {
		self.init(options, rules: {[:]} )
    }
    
    let options: TraceryOptions
    
    public init(_ options: TraceryOptions = TraceryOptions.defaultSet, rules: () -> [String: Any]) {
		
		self.options = options
		self.tagStorage = options.tagStorageType.storage()
		self.contextStack = ContextStack()
		super.init()
		self.tagStorage.tracery = self

		if options.isDeterministic {
			setSeed(options.seed)
		}
		
	    let rules = rules()
        
        rules.forEach { rule, value in
            add(rule: rule, definition: value)
        }
		
		if options.useStandardModifiers {
			StandardModifiers.installStandardModifiers(t: self)
		}
        analyzeRuleBook()

        info("tracery ready")
    }
	
	public func setSeed(_ seed:Int) {
		var s = seed
		let data = withUnsafePointer(to: &s) {
			Data(bytes: UnsafePointer($0), count: MemoryLayout.size(ofValue: seed))
		}
		randomSource_ = DeterministicRandomSource( seed: data )
	}
    
    func createRuleCandidate(rule:String, text: String) -> RuleCandidate? {
        let e = error
        do {
            info("checking rule '\(rule)' - \(text)")
            return RuleCandidate(
                text: text,
                value: ValueCandidate(nodes: try Parser.gen2(Lexer.tokens(text)))
            )
        }
        catch {
            e("rule '\(rule)' parse error - \(error)")
            return nil
        }
    }
	
    public func add(modifier: String, transform: @escaping (String)->String) {
        if mods[modifier] != nil {
            warn("overwriting modifier '\(modifier)'")
        }
        mods[modifier] = { input, _ in
            return transform(input)
        }
    }
    
    public func add(call: String, transform: @escaping (String, [String]) -> ()) {
        if mods[call] != nil {
            warn("overwriting call '\(call)'")
        }
        mods[call] = { input, params in
            transform(input, params)
            return input
        }
    }
    
    public func add(method: String, transform: @escaping (String, [String])->String) {
        if mods[method] != nil {
            warn("overwriting method '\(method)'")
        }
        mods[method] = transform
    }
    
    public func setCandidateSelector(rule: String, selector: RuleCandidateSelector) {
        guard ruleSet[rule] != nil else {
            warn("rule '\(rule)' not found to set selector")
            return
        }
        ruleSet[rule]?.selector = selector
    }
    
    public func expand(_ input: String, maintainContext: Bool = false) -> String {
        do {
            if !maintainContext {
                ruleEvaluationLevel = 0
                runTimeRuleSet.removeAll()
                tagStorage.removeAll()
            }
            return try eval(input)
        }
        catch {
            return "error: \(error)"
        }
    }
    
    public static var maxStackDepth = 256
    
    fileprivate(set) var ruleEvaluationLevel: Int = 0
    
    func incrementEvaluationLevel() throws {
        ruleEvaluationLevel += 1
        // trace("⚙️ depth: \(ruleEvaluationLevel)")
        if ruleEvaluationLevel > Tracery.maxStackDepth {
            error("stack overflow")
            throw ParserError.error("stack overflow")
        }
    }
    
    func decrementEvaluationLevel() {
        ruleEvaluationLevel = max(ruleEvaluationLevel - 1, 0)
        // trace("⚙️ depth: \(ruleEvaluationLevel)")
    }
}



// MARK: Rule management
extension Tracery {
    // add a rule and its definition to
    // the mapping table
    // errors if any are returned
    public func add(rule: String, definition value: Any) {
        
        // validate the rule name
        if ruleSet[rule] != nil {
            warn("rule '\(rule)' will be re-written")
        }
		
        let values: [String]
        
        if let provider = value as? RuleCandidatesProvider {
            values = provider.candidates
        }
        else if let string = value as? String {
            values = [string]
        }
        else if let array = value as? [String] {
            values = array
        }
        else if let array = value as? Array<CustomStringConvertible> {
            values = array.map { $0.description }
        }
        else {
            values = ["\(value)"]
        }
        
		let candidates = values.compactMap { createRuleCandidate(rule: rule, text: $0) }
        if candidates.count == 0 {
            warn("rule '\(rule)' ignored - no expansion candidates found")
            return
        }
        
        let selector: RuleCandidateSelector
        if let s = value as? RuleCandidateSelector {
            selector = s
        }
        else {
            selector = candidates.map { $0.value }.selector()
        }
        
		if rule.hasSuffix(".") {
			// remove the dot
			let r = String(rule[rule.startIndex..<rule.index(before: rule.endIndex)])
			// set selector to sequential
			ruleSet[r] = RuleMapping(candidates: candidates, selector: SequentialSelector())
			return
		}
        let tokens = Lexer.tokens(rule)
        guard tokens.count == 1, case .text = tokens[0] else {
            error("rule '\(rule)' ignored - names must be plaintext")
            return
        }

        ruleSet[rule] = RuleMapping(candidates: candidates, selector: selector)
    }
    
    // Removes a rule
    public func remove(rule: String) {
        ruleSet[rule] = nil
    }
}

// MARK: object management
extension Tracery {

    public func add(object: Any, named name: String) {
        objects[name] = object
    }
    
    public func remove(object name: String) {
        objects[name] = nil
    }
    
    public func configuredObjects() -> [String: Any] {
        return objects
    }
    
}

