//
//  Tracery.Text.swift
//  Tracery
//
//  Created by Benzi on 21/03/17.
//  Copyright © 2017 Benzi Ahamed. All rights reserved.
//

import Foundation


// File format that can scan plain text. Newlines are necessary

// [rule1]
// candidate 1
// candidate 2
//
// [rule2]
// candidate 1
// candidate 2
//

extension String {
	func trimTrailingSpaces() -> String {
		var t = self
		while t.hasSuffix(" ") {
			t = "" + t.dropLast()
		}
		return t
	}
	
	func trimLeadingSpaces() -> String {
		var t = self
		while t.hasPrefix(" ") {
			t = "" + t.dropFirst()
		}
		return t
	}
	
	func trimSpaces() -> String {
		return self.trimLeadingSpaces().trimTrailingSpaces()
	}
	
	mutating func trimEnd() {
		self = self.trimTrailingSpaces()
	}
	mutating func trimStart() {
		self = self.trimLeadingSpaces()
	}
	mutating func trim() {
		self = self.trimLeadingSpaces().trimTrailingSpaces()
	}

}

extension Tracery {
    
    convenience public init(_ options: TraceryOptions = TraceryOptions.defaultSet, path: String) {
        if let reader = StreamReader(path: path) {
            self.init ( options, rules: { TextParser.parse(lines: reader) } )
        }
        else {
            warn("unable to parse input file: \(path)")
            self.init()
        }
    }
    
    convenience public init(_ options: TraceryOptions = TraceryOptions.defaultSet, lines: [String]) {
		self.init ( options, rules: { TextParser.parse(lines: lines) } )
    }
    
}

struct TextParser {
    
    enum State {
        case consumeRule
        case consumeDefinitions
    }
    
    static func parse<S: Sequence>(lines: S) -> [String: Any] where S.Iterator.Element == String {
        
        var ruleSet = [String: [String] ]()
        var rule = ""
		
        for line in lines {
			// ignore comments and blank lines
			if line.hasPrefix("\\") || line.count == 0 {
				continue
			}

			if line.hasPrefix("[") && line.hasSuffix("]") && !line.hasPrefix("[while") {
				let start = line.index(after: line.startIndex)
				let end = line.index(before: line.endIndex)
				rule = String(line[start..<end])
				if ruleSet[rule] != nil {
					warn("rule '\(rule)' defined twice, will be overwritten")
				}
				ruleSet[rule] = [String]()
			} else {
				if rule != "" {
					ruleSet[rule]!.append(line)
				}
            }
        }
		
        return ruleSet
    }
    
}

class StreamReader  {
    
    let encoding : String.Encoding
    let chunkSize : Int
    
    var fileHandle : FileHandle!
    let buffer : NSMutableData!
    let delimData : Data!
    var atEof : Bool = false
    
    init?(path: String, delimiter: String = "\n", encoding: String.Encoding = .utf8, chunkSize : Int = 4096) {
        self.chunkSize = chunkSize
        self.encoding = encoding
        
        if let fileHandle = FileHandle(forReadingAtPath: path),
            let delimData = delimiter.data(using: encoding),
            let buffer = NSMutableData(capacity: chunkSize)
        {
            self.fileHandle = fileHandle
            self.delimData = delimData
            self.buffer = buffer
        } else {
            self.fileHandle = nil
            self.delimData = nil
            self.buffer = nil
            return nil
        }
    }
    
    deinit {
        self.close()
    }
    
    /// Return next line, or nil on EOF.
    func nextLine() -> String? {
        precondition(fileHandle != nil, "Attempt to read from closed file")
        
        if atEof {
            return nil
        }
        
        // Read data chunks from file until a line delimiter is found:
        var range = buffer.range(of: delimData, options: [], in: NSMakeRange(0, buffer.length))
        while range.location == NSNotFound {
            let tmpData = fileHandle.readData(ofLength: chunkSize)
            if tmpData.count == 0 {
                // EOF or read error.
                atEof = true
                if buffer.length > 0 {
                    // Buffer contains last line in file (not terminated by delimiter).
                    let line = String(data: buffer as Data, encoding: encoding)
                    
                    buffer.length = 0
                    return line as String?
                }
                // No more lines.
                return nil
            }
            buffer.append(tmpData)
            range = buffer.range(of: delimData, options: [], in: NSMakeRange(0, buffer.length))
        }
        
        // Convert complete line (excluding the delimiter) to a string:
        let line = String(data: buffer.subdata(with: NSMakeRange(0, range.location)),
                            encoding: encoding)
        // Remove line (and the delimiter) from the buffer:
        buffer.replaceBytes(in: NSMakeRange(0, range.location + range.length), withBytes: nil, length: 0)
        
        return line
    }
    
    /// Start reading from the beginning of file.
    func rewind() -> Void {
        fileHandle.seek(toFileOffset: 0)
        buffer.length = 0
        atEof = false
    }
    
    /// Close the underlying file. No reading must be done after calling this method.
    func close() -> Void {
        fileHandle?.closeFile()
        fileHandle = nil
    }
}

extension StreamReader: Sequence {
    func makeIterator() -> AnyIterator<String> {
        return AnyIterator<String> {
            return self.nextLine()
        }
    }
}


