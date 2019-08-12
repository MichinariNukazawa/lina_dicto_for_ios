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
        XCTAssertEqual(Esperanto.isEsperanto(word: "Bona"), true)     // 1word
        XCTAssertEqual(Esperanto.isEsperanto(word: "Cxu"), true)      // x-sistemo
        XCTAssertEqual(Esperanto.isEsperanto(word: "C^u"), true)      // (caret)^-sistemo
        XCTAssertEqual(Esperanto.isEsperanto(word: "U~"), true)       // ^-sistemo
        XCTAssertEqual(Esperanto.isEsperanto(word: "ĉu"), true)       // alfabeto
        XCTAssertEqual(Esperanto.isEsperanto(word: "Amrilato"), true)
        XCTAssertEqual(Esperanto.isEsperanto(word: "Bonan matenon"), true)   // 2word
        XCTAssertEqual(Esperanto.isEsperanto(word: "Amrilato."), true)
        XCTAssertEqual(Esperanto.isEsperanto(word: "Bonan matenon!"), true)
        XCTAssertEqual(Esperanto.isEsperanto(word: "Kiso?"), true)
        //XCTAssertEqual(Esperanto.isEsperanto(word: "Bonan matenon!"), true)   // !
        //XCTAssertEqual(Esperanto.isEsperanto(word: "Bonan matenon."), true)   // .
        XCTAssertEqual(Esperanto.isEsperanto(word: "おはよう"), false)       // ja
        XCTAssertEqual(Esperanto.isEsperanto(word: "恋仲"), false)          // ja
        XCTAssertEqual(Esperanto.isEsperanto(word: "Cxu恋仲"), false)       // ja joined
        XCTAssertEqual(Esperanto.isEsperanto(word: "Cxuおはよう"), false)    // ja joined

        
        XCTAssertEqual(Esperanto.convertCaretFromAnySistemo(str: "Ĉu"), "C^u");  // alfabeto
        XCTAssertEqual(Esperanto.convertCaretFromAnySistemo(str: "ĉu"), "c^u");  // alfabeto
        XCTAssertEqual(Esperanto.convertCaretFromAnySistemo(str: "Ŭ"), "U^");    // alfabeto
        XCTAssertEqual(Esperanto.convertCaretFromAnySistemo(str: "Cxu"), "C^u"); // x-systemo
        XCTAssertEqual(Esperanto.convertCaretFromAnySistemo(str: "Cxxu"), "C^u"); // x-systemo
        XCTAssertEqual(Esperanto.convertCaretFromAnySistemo(str: "Cxxu Ŭ"), "C^u U^"); // multi

        XCTAssertEqual(Esperanto.convertAlfabetoFromCaretSistemo(str: "C^u"), "Ĉu");
        XCTAssertEqual(Esperanto.convertAlfabetoFromCaretSistemo(str: "c^u"), "ĉu");
        XCTAssertEqual(Esperanto.convertAlfabetoFromCaretSistemo(str: "U^"), "Ŭ");
        XCTAssertEqual(Esperanto.convertAlfabetoFromCaretSistemo(str: "U~"), "Ŭ");
        XCTAssertEqual(Esperanto.convertAlfabetoFromCaretSistemo(str: "U~c^"), "Ŭĉ"); // multi
        
        XCTAssertEqual(Esperanto.convertAlfabetoFromAnySistemo(str: "U~c^Cxx"), "ŬĉĈ"); // multi
    }
    
    func testDictionary(){
        let linad = LDictionary()
        linad.initialize()
        var responses :[SearchResponseItem]
        
        // ** 1word単語マッチ uppercase
        responses = linad.search(searchKey: "Bona")
        XCTAssertEqual(responses.count, 1)
        XCTAssertEqual(responses[0].lang, "eo")
        XCTAssertEqual(responses[0].matchedKeyword, "Bona")
        XCTAssertEqual(responses[0].modifyKind, "")
        XCTAssertEqual(responses[0].matchItems.count, 1)
        
        // 1word単語マッチ lowercase
        responses = linad.search(searchKey: "bona")
        XCTAssertEqual(responses.count, 1)
        XCTAssertEqual(responses[0].lang, "eo")
        XCTAssertEqual(responses[0].matchedKeyword, "bona")
        XCTAssertEqual(responses[0].matchItems.count, 1)

        // 1word 末尾記号
        responses = linad.search(searchKey: "Amrilato")
        XCTAssertEqual(responses.count, 1)
        XCTAssertEqual(responses[0].lang, "eo")
        XCTAssertEqual(responses[0].matchedKeyword, "Amrilato")
        XCTAssertEqual(responses[0].matchItems.count, 1)
        responses = linad.search(searchKey: "Amrilato.")
        XCTAssertEqual(responses.count, 1)
        XCTAssertEqual(responses[0].lang, "eo")
        XCTAssertEqual(responses[0].matchedKeyword, "Amrilato")
        XCTAssertEqual(responses[0].matchItems.count, 1)
        
        // 不正文字失敗
        responses = linad.search(searchKey: "Xxxxx")
        XCTAssertEqual(responses.count, 1)
        XCTAssertEqual(responses[0].lang, "eo")
        XCTAssertEqual(responses[0].matchedKeyword, "Xxxxx")
        XCTAssertEqual(responses[0].matchItems.count, 0)
        // 空文字失敗
        responses = linad.search(searchKey: "")
        XCTAssertEqual(responses.count, 0)
        //XCTAssertEqual(responses[0].matchedKeyword, "")
        //XCTAssertEqual(responses[0].matchItems.count, 0)

        // ** 2word単語マッチ
        responses = linad.search(searchKey: "Bonan matenon!")
        XCTAssertEqual(responses.count, 1)
        XCTAssertEqual(responses[0].lang, "eo")
        XCTAssertEqual(responses[0].matchedKeyword, "Bonan matenon")
        XCTAssertEqual(responses[0].matchItems.count, 1)

        // ** 空白文字対応
        responses = linad.search(searchKey: " Bonan   matenon! ")
        XCTAssertEqual(responses.count, 1)
        XCTAssertEqual(responses[0].lang, "eo")
        XCTAssertEqual(responses[0].matchedKeyword, "Bonan matenon")
        XCTAssertEqual(responses[0].matchItems.count, 1)
        
        // ** sistemo
        responses = linad.search(searchKey: "C^u")  // ^-sistemo
        XCTAssertEqual(responses.count, 1)
        XCTAssertEqual(responses[0].lang, "eo")
        XCTAssertEqual(responses[0].matchItems.count, 1)
        responses = linad.search(searchKey: "Ĉu")   // alfabeto
        XCTAssertEqual(responses.count, 1)
        XCTAssertEqual(responses[0].lang, "eo")
        XCTAssertEqual(responses[0].matchItems.count, 1)
        responses = linad.search(searchKey: "Cxu")  // x-sistemo
        XCTAssertEqual(responses.count, 1)
        XCTAssertEqual(responses[0].lang, "eo")
        XCTAssertEqual(responses[0].matchItems.count, 1)
        responses = linad.search(searchKey: "Cxxu") // x-sistemo
        XCTAssertEqual(responses.count, 1)
        XCTAssertEqual(responses[0].lang, "eo")
        XCTAssertEqual(responses[0].matchItems.count, 1)
        
        // ** 1 word near match
        responses = linad.search(searchKey: "estas")
        XCTAssertEqual(responses.count, 1)
        XCTAssertEqual(responses[0].lang, "eo")
        XCTAssertEqual(responses[0].matchedKeyword, "estas")
        XCTAssertEqual(responses[0].modifyKind, "verbo candidates")
        XCTAssertEqual(responses[0].matchItems.count, 1)

        // ** multi word multi str match
        responses = linad.search(searchKey: "Kio estas cxi tio.")
        XCTAssertEqual(responses.count, 3)
        XCTAssertEqual(responses[0].lang, "eo")
        XCTAssertEqual(responses[0].matchedKeyword, "Kio")
        XCTAssertEqual(responses[0].modifyKind, "")
        XCTAssertEqual(responses[0].matchItems.count, 1)
        XCTAssertEqual(responses[0].matchItems[0].searchKeyword, "kio")
        XCTAssertEqual(responses[1].lang, "eo")
        XCTAssertEqual(responses[1].matchedKeyword, "estas")
        XCTAssertEqual(responses[1].modifyKind, "verbo candidates")
        XCTAssertEqual(responses[1].matchItems.count, 1)
        //XCTAssertEqual(responses[1].matchItem?.searchKeyword, "estas")
        XCTAssertEqual(responses[2].lang, "eo")
        XCTAssertEqual(responses[2].matchedKeyword, "c^i tio")
        XCTAssertEqual(responses[2].matchItems.count, 1)
        XCTAssertEqual(responses[2].matchItems[0].searchKeyword, "c^i tio")
        
        // ** japanese 1word match
        responses = linad.search(searchKey: "恋愛関係")
        XCTAssertEqual(responses.count, 1)
        XCTAssertEqual(responses[0].lang, "ja")
        XCTAssertEqual(responses[0].matchedKeyword, "恋愛関係")
        XCTAssertEqual(responses[0].matchItems.count, 1)
        XCTAssertEqual(responses[0].matchItems[0].searchKeyword, "amrilato")

        // ignoring double-word symbol character ex."？"
        responses = linad.search(searchKey: "おはよう")
        XCTAssertEqual(responses.count, 1)
        XCTAssertEqual(responses[0].lang, "ja")
        XCTAssertEqual(responses[0].matchedKeyword, "おはよう")
        XCTAssertEqual(responses[0].matchItems.count, 1)
        XCTAssertEqual(responses[0].matchItems[0].searchKeyword, "bonan matenon")
        responses = linad.search(searchKey: "おはよう！")
        XCTAssertEqual(responses.count, 1)
        XCTAssertEqual(responses[0].lang, "ja")
        XCTAssertEqual(responses[0].matchedKeyword, "おはよう！")
        XCTAssertEqual(responses[0].matchItems.count, 1)
        XCTAssertEqual(responses[0].matchItems[0].searchKeyword, "bonan matenon")

        // ** japanese 1word not match
        responses = linad.search(searchKey: "恋仲")
        XCTAssertEqual(responses.count, 1)
        XCTAssertEqual(responses[0].lang, "ja")
        XCTAssertEqual(responses[0].matchedKeyword, "恋仲")
        XCTAssertEqual(responses[0].matchItems.count, 0)
    }
    
    func testTokenize(){
        let data = [
            ["disk", ["disk"]],
            ["-emulo", ["-emulo"]], // 接尾辞表記 [Praktika Esperanto-Japana Vortareto.]( https://www.vastalto.com/jpn/ )
            ["kotonoha amrilato", ["kotonoha", "amrilato"]],
            ["        disk", ["disk"]], // 空白除去
            [" kotonoha    amrilato ", ["kotonoha", "amrilato"]],
            ["Kio estas tio?", ["Kio", "estas", "tio"]], // 末尾記号は消える
            ["Ĉu vi amas s^in?", ["Ĉu", "vi", "amas", "s^in"]], // ^-sistemo alfabeto
            ["Cxu vi amas s^in?", ["Cxu", "vi", "amas", "s^in"]], // ^-sistemo x-sistemo
            ["Fomalhaŭt/o", ["Fomalhaŭt/o"]],  // alfabeto
            ["Fomalhau~t/o", ["Fomalhau~t/o"]], // ^-sistemo && `~`を含む単語の動作確認
            ["Sxia(Rin).", ["Sxia", "Rin"]], // 記号
            ["SukeraSparo", ["Sukera", "Sparo"]], // 大文字始まりは大文字を区切り
            // TODO ["kHz", ["kHz"]], // 大文字始まりでなければ大文字区切りしない
            ["LKK", ["LKK"]], // 大文字始まりでなければ大文字区切りしない
            ["Uaz", ["Uaz"]], // 小文字が前になければ大文字区切りしない
            ["TV-stacio", ["TV-stacio"]], // 小文字が前になければ大文字区切りしない
            ["SukeraSparoのスペースにPanoを持ってくると", ["Sukera", "Sparo", "のスペースに", "Pano", "を持ってくると"]], // 日本語混在
        ]
        
        for d in data{
            let key :String = d[0] as! String
            let value :[String] = d[1] as! [String]
            let res = Tokenizer.preTokenizeEsperanto(text: key)
            XCTAssertEqual(res, value)
        }

        
        let dataA = [
            ["Cxu vi amas s^in?", ["Cxu", "vi", "amas", "s^in"]], // ^-sistemo x-sistemo
            ["Kio estas cxi tio.", ["Kio", "estas", "cxi", "tio"]],
//            ["SukeraSparoのスペースにPanoを持ってくると", ["Sukera", "Sparo", "の", "スペース", "に", "Pano", "を", "持っ", "て", "くる", "と"]], // 日本語混在
        ]

        for d in dataA{
            let key :String = d[0] as! String
            let value :[String] = d[1] as! [String]
            let res = Tokenizer.tokenize(text: key)
            XCTAssertEqual(res, value)
        }
    }
}
