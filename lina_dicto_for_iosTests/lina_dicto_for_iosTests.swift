//
//  lina_dicto_for_iosTests.swift
//  lina_dicto_for_iosTests
//
//  Created by Michinari Nukazawa on 2019/07/26.
//  Copyright © 2019 Michinari Nukazawa. All rights reserved.
//

import XCTest
@testable import lina_dicto_for_ios

class lina_dicto_for_iosTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testEsperanto(){
        //** esperanto文字列判定
        XCTAssertEqual(isEsperanto(word: "Bona"), true)     // 1word
        XCTAssertEqual(isEsperanto(word: "Cxu"), true)      // x-sistemo
        XCTAssertEqual(isEsperanto(word: "C^u"), true)      // (caret)^-sistemo
        XCTAssertEqual(isEsperanto(word: "U~"), true)       // ^-sistemo
        XCTAssertEqual(isEsperanto(word: "ĉu"), true)       // alfabeto
        XCTAssertEqual(isEsperanto(word: "Amrilato"), true)
        XCTAssertEqual(isEsperanto(word: "Bonan matenon"), true)   // 2word
        //XCTAssertEqual(isEsperanto(word: "Bonan matenon!"), true)   // !
        //XCTAssertEqual(isEsperanto(word: "Bonan matenon."), true)   // .
        XCTAssertEqual(isEsperanto(word: "おはよう"), false)       // ja
        XCTAssertEqual(isEsperanto(word: "恋仲"), false)          // ja
        XCTAssertEqual(isEsperanto(word: "Cxu恋仲"), false)       // ja joined
        XCTAssertEqual(isEsperanto(word: "Cxuおはよう"), false)    // ja joined

        
        XCTAssertEqual(convertCaretFromAnySistemo(str: "Ĉu"), "C^u");  // alfabeto
        XCTAssertEqual(convertCaretFromAnySistemo(str: "ĉu"), "c^u");  // alfabeto
        XCTAssertEqual(convertCaretFromAnySistemo(str: "Ŭ"), "U^");    // alfabeto
        XCTAssertEqual(convertCaretFromAnySistemo(str: "Cxu"), "C^u"); // x-systemo
        XCTAssertEqual(convertCaretFromAnySistemo(str: "Cxxu"), "C^u"); // x-systemo
        XCTAssertEqual(convertCaretFromAnySistemo(str: "Cxxu Ŭ"), "C^u U^"); // multi

        XCTAssertEqual(convertAlfabetoFromCaretSistemo(str: "C^u"), "Ĉu");
        XCTAssertEqual(convertAlfabetoFromCaretSistemo(str: "c^u"), "ĉu");
        XCTAssertEqual(convertAlfabetoFromCaretSistemo(str: "U^"), "Ŭ");
        XCTAssertEqual(convertAlfabetoFromCaretSistemo(str: "U~"), "Ŭ");
        XCTAssertEqual(convertAlfabetoFromCaretSistemo(str: "U~c^"), "Ŭĉ"); // multi
        
        XCTAssertEqual(convertAlfabetoFromAnySistemo(str: "U~c^Cxx"), "ŬĉĈ"); // multi
    }
    
    func testDictionary(){
        let linad = LDictionary()
        linad.initialize()
        var responses :[SearchResponseItem]
        
        // ** 1word単語マッチ uppercase
        responses = linad.search(searchKey: "Bona")
        XCTAssertEqual(responses.count, 1)
        XCTAssertEqual(responses[0].matchedKeyword, "Bona")
        XCTAssertNotNil(responses[0].matchItem)
        
        // 1word単語マッチ lowercase
        responses = linad.search(searchKey: "bona")
        XCTAssertEqual(responses.count, 1)
        XCTAssertEqual(responses[0].matchedKeyword, "bona")
        XCTAssertNotNil(responses[0].matchItem)

        // 1word 末尾記号
        responses = linad.search(searchKey: "Amrilato")
        XCTAssertEqual(responses.count, 1)
        XCTAssertEqual(responses[0].matchedKeyword, "Amrilato")
        XCTAssertNotNil(responses[0].matchItem)
        responses = linad.search(searchKey: "Amrilato.")
        XCTAssertEqual(responses.count, 1)
        XCTAssertEqual(responses[0].matchedKeyword, "Amrilato")
        XCTAssertNotNil(responses[0].matchItem)
        
        // 不正文字失敗
        responses = linad.search(searchKey: "Xxxxx")
        XCTAssertEqual(responses.count, 1)
        XCTAssertEqual(responses[0].matchedKeyword, "Xxxxx")
        XCTAssertNil(responses[0].matchItem)
        // 空文字失敗
        responses = linad.search(searchKey: "")
        XCTAssertEqual(responses.count, 0)
        //XCTAssertEqual(responses[0].matchedKeyword, "")
        //XCTAssertNil(responses[0].matchItem)

        // ** 2word単語マッチ
        responses = linad.search(searchKey: "Bonan matenon!")
        XCTAssertEqual(responses.count, 1)
        XCTAssertEqual(responses[0].matchedKeyword, "Bonan matenon")
        XCTAssertNotNil(responses[0].matchItem)

        // ** 空白文字対応
        responses = linad.search(searchKey: " Bonan   matenon! ")
        XCTAssertEqual(responses.count, 1)
        XCTAssertEqual(responses[0].matchedKeyword, "Bonan matenon")
        XCTAssertNotNil(responses[0].matchItem)
        
        // ** sistemo
        responses = linad.search(searchKey: "C^u")  // ^-sistemo
        XCTAssertEqual(responses.count, 1)
        XCTAssertNotNil(responses[0].matchItem)
        responses = linad.search(searchKey: "Ĉu")   // alfabeto
        XCTAssertEqual(responses.count, 1)
        XCTAssertNotNil(responses[0].matchItem)
        responses = linad.search(searchKey: "Cxu")  // x-sistemo
        XCTAssertEqual(responses.count, 1)
        XCTAssertNotNil(responses[0].matchItem)
        responses = linad.search(searchKey: "Cxxu") // x-sistemo
        XCTAssertEqual(responses.count, 1)
        XCTAssertNotNil(responses[0].matchItem)
        
        // ** multi word multi str match
        responses = linad.search(searchKey: "Kio estas cxi tio.")
        XCTAssertEqual(responses.count, 3)
        XCTAssertEqual(responses[0].matchedKeyword, "Kio")
        XCTAssertNotNil(responses[0].matchItem)
        XCTAssertEqual(responses[0].matchItem?.searchKeyword, "kio")
        XCTAssertEqual(responses[1].matchedKeyword, "estas")
        XCTAssertNil(responses[1].matchItem)
        //XCTAssertEqual(responses[1].matchItem?.searchKeyword, "estas")
        XCTAssertEqual(responses[2].matchedKeyword, "c^i tio")
        XCTAssertNotNil(responses[2].matchItem)
        XCTAssertEqual(responses[2].matchItem?.searchKeyword, "c^i tio")
    }
}
