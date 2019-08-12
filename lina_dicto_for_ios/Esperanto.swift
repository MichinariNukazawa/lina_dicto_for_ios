//
//  Esperanto.swift
//  lina_dicto_for_ios
//
//  Created by Michinari Nukazawa on 2019/08/13.
//  Copyright © 2019 Michinari Nukazawa. All rights reserved.
//

import Foundation

extension String {
    //絵文字など(2文字分)も含めた文字数を返します
    var length: Int {
        let string_NS = self as NSString
        return string_NS.length
    }
    
    //正規表現の検索をします
    func pregMatche(pattern: String, options: NSRegularExpression.Options = []) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return false
        }
        let matches = regex.matches(in: self, options: [], range: NSMakeRange(0, self.length))
        return matches.count > 0
    }
}

class Esperanto{
    // esperantoワードか（含む文字かチェック）
    static func isEsperanto(word :String) -> Bool {
        // 厳密なマッチではないけれど、日本語と区別できればOK
        let pattern = "^[A-Za-z0-9\u{0108}-\u{016D}\\s^~.\\!\\?-]+$"
        return word.pregMatche(pattern: pattern)
    }

    static func convertCaretFromAnySistemo(str :String) -> String{
        var res = str
        
        let replaces = [
            ["\u{0108}", "C"],
            ["\u{0109}", "c"],
            ["\u{011C}", "G"],
            ["\u{011D}", "g"],
            ["\u{0124}", "H"],
            ["\u{0125}", "h"],
            ["\u{0134}", "J"],
            ["\u{0135}", "j"],
            ["\u{015C}", "S"],
            ["\u{015D}", "s"],
            ["\u{016C}", "U"],
            ["\u{016D}", "u"],
            ["\u{016C}", "U"],
            ["\u{016D}", "u"],
        ]
        
        for r in replaces{
            // ** x-sistemo
            res = res.replacingOccurrences(of: r[1] + "xx", with: r[1] + "^")
            // ** x-sistemo
            res = res.replacingOccurrences(of: r[1] + "x" , with: r[1] + "^")
            // ** caret-sistemo
            // res = res.replacingOccurrences(of: r[1] + "^", with: r[1] + "^")
            // ** caret-sistemo ("~" -> "^")
            res = res.replacingOccurrences(of: "U~", with: "U^")
            res = res.replacingOccurrences(of: "u~", with: "u^")
            // ** alfabeto
            res = res.replacingOccurrences(of: r[0], with: r[1] + "^")
        }
        return res
    }
    
    static func convertAlfabetoFromCaretSistemo(str :String) -> String{
        let replaces = [
            ["\u{0108}", "C^"],
            ["\u{0109}", "c^"],
            ["\u{011C}", "G^"],
            ["\u{011D}", "g^"],
            ["\u{0124}", "H^"],
            ["\u{0125}", "h^"],
            ["\u{0134}", "J^"],
            ["\u{0135}", "j^"],
            ["\u{015C}", "S^"],
            ["\u{015D}", "s^"],
            ["\u{016C}", "U^"],
            ["\u{016D}", "u^"],
            ["\u{016C}", "U~"],
            ["\u{016D}", "u~"],
        ]
        
        var dst = str
        for r in replaces{
            dst = dst.replacingOccurrences(of: r[1], with: r[0])
        }
        
        return dst
    }
    
    static func convertAlfabetoFromAnySistemo(str :String) -> String{
        return convertAlfabetoFromCaretSistemo(str: convertCaretFromAnySistemo(str: str))
    }

    static let finajxoj :[String] = [
        "i",
        "as",
        "is",
        "os",
        "us",
        "u"
    ];
    
    //! 語根を返す
    static func convertRadico(str: String) -> String{
        var radico = str
        
        radico = radico.replacingOccurrences(of: "j$", with: "", options: .regularExpression)
        
        for finajxo in finajxoj{
            radico = radico.replacingOccurrences(of: "\(finajxo)$", with: "", options: .regularExpression)
        }
        
        return radico
    }
    
    //! 動詞語尾変換候補一覧があれば返す
    static func generateVerboCandidate(str: String) -> [String]{
        let radico = convertRadico(str: str)
        
        if(str == radico){
            return []
        }
        
        var candidate :[String] = []
        for finajxo in finajxoj{
            candidate.append(radico + finajxo)
        }
        
        return candidate
    }
}
