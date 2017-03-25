//
//  Performance.swift
//  Tracery
//
//  Created by Benzi on 11/03/17.
//  Copyright © 2017 Benzi Ahamed. All rights reserved.
//

import XCTest
@testable import Tracery

class Performance: XCTestCase {

    func testPerformanceOfStoryGrammarFromTraceryIO() {
        self.measure {
            let t = Tracery {[
                "name": ["Arjun","Yuuma","Darcy","Mia","Chiaki","Izzi","Azra","Lina"]
                ,	"animal": ["unicorn","raven","sparrow","scorpion","coyote","eagle","owl","lizard","zebra","duck","kitten"]
                ,	"occupationBase": ["wizard","witch","detective","ballerina","criminal","pirate","lumberjack","spy","doctor","scientist","captain","priest"]
                ,	"occupationMod": ["occult ","space ","professional ","gentleman ","erotic ","time ","cyber ","paleo ","techno ","super "]
                ,	"strange": ["mysterious","portentous","enchanting","strange","eerie"]
                ,	"tale": ["story","saga","tale","legend"]
                ,	"occupation": ["#occupationMod##occupationBase#"]
                ,	"mood": ["vexed","indignant","impassioned","wistful","astute","courteous"]
                ,	"setPronouns": ["[heroThey:they][heroThem:them][heroTheir:their][heroTheirs:theirs]","[heroThey:she][heroThem:her][heroTheir:her][heroTheirs:hers]","[heroThey:he][heroThem:him][heroTheir:his][heroTheirs:his]"]
                ,	"setSailForAdventure": ["set sail for adventure","left #heroTheir# home","set out for adventure","went to seek #heroTheir# forture"]
                ,	"setCharacter": ["[#setPronouns#][hero:#name#][heroJob:#occupation#]"]
                ,	"openBook": ["An old #occupation# told #hero# a story. 'Listen well' she said to #hero#, 'to this #strange# #tale#. ' #origin#'","#hero# went home.","#hero# found an ancient book and opened it.  As #hero# read, the book told #strange.a# #tale#: #origin#"]
                ,	"story": ["#hero# the #heroJob# #setSailForAdventure#. #openBook#"]
                ,	"origin": ["Once upon a time, #[#setCharacter#]story#"]
                ]}
            print(t.expand("- #origin#"))
        }
    }

    
    func test() {
        
        // Tracery.logLevel = .verbose
        // let tokens = Lexer.tokens("[if name == benzi then ok]")
        let tokens = Lexer.tokens("[tag:value1:up#many#,value2:10]")
        // let tokens = Lexer.tokens("#.name(#a#)###")
        // let tokens = Lexer.tokens("[lemons:pie,#maybe#]")
        let nodes = try! Parser.gen2(tokens)
        
        print(tokens)
        print(nodes)
        
        
    }

}


