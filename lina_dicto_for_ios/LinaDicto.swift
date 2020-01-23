//
//  LinaDicto.swift
//  lina_dicto_for_ios
//
//  Created by Michinari Nukazawa on 2019/08/13.
//  Copyright © 2019 Michinari Nukazawa. All rights reserved.
//

import Foundation

func log(debug: Any = "",
         function: String = #function,
         file: String = #file,
         line: Int = #line) {
    var filename = file
    if let nss = NSString(utf8String: filename){
        filename = nss.lastPathComponent
    }
    Swift.print("Log:\(filename):L\(line):\(function) \(debug)")
}

// ------------
//
// ------------

extension String {
    func removeCharacters(from forbiddenChars: CharacterSet) -> String {
        let passed = self.unicodeScalars.filter { !forbiddenChars.contains($0) }
        return String(String.UnicodeScalarView(passed))
    }
    
    func removeCharacters(from: String) -> String {
        return removeCharacters(from: CharacterSet(charactersIn: from))
    }
}

// URLエンコード
func encodingUrlEncode(string: String) -> String {
    return string.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
}

// google翻訳のURLを生成
func generateGoogleTranslateUrl(keyword :String, src_lang :String, dst_lang :String) -> String {
    // ex. eo to ja, `https://translate.google.co.jp/#eo/ja/bona`
    let link = "https://translate.google.co.jp"
        + "/#" + src_lang
        + "/" + dst_lang
        + "/" + encodingUrlEncode(string: keyword)
    return link
}

// ------------
//
// ------------

struct Tokenizer {
    
    //let patternLowerCase =
    
    // 記号で分割する(記号の除去を兼ねる)
    // TODO エスペラント文字列とそれ以外で分割する
    // TODO 大文字始まりで小文字に続く大文字で分割する
    
    static func preTokenizeEsperanto(text: String) -> [String]{
        let patternEsperantoChar = "[A-Za-z0-9 \u{0108}-\u{016D}\\s^~\\ß/-]"
        let patternUpperCase = "A-Z\u{0108}\u{011C}\u{0124}\u{0134}\u{015C}\u{016C}"
        
        var t :String = text
        // "-,/"は除去・分割対象に含めない。
        t = t.replacingOccurrences(of: "[,._?!()|]+", with: " ", options: .regularExpression)
        t = t.replacingOccurrences(of: "([\(patternUpperCase)]+[^\(patternUpperCase)])", with: " $1", options: .regularExpression)
        t = t.replacingOccurrences(of: "[\(patternEsperantoChar)]+", with: " $0 ", options: .regularExpression)
        t = t.replacingOccurrences(of: "//s+", with: " ", options: .regularExpression)
        let r = t.split(separator: " ")
        return r.map(String.init)
    }
    
    // MARK: - Publics
    static func preTokenizeJapanese(text: String) -> [String] {
        let range = text.startIndex ..< text.endIndex
        var tokens: [String] = []
        
        text.enumerateSubstrings(in: range, options: .byWords) { (substring, _, _, _) -> () in
            if let substring = substring {
                tokens.append(substring)
            }
        }
        
        return tokens
    }
    
    static func tokenize(text: String) -> [String]{
        let ss1 = preTokenizeEsperanto(text: text)
        var ss2 : [String] = []
        for s in ss1{
            if(Esperanto.isEsperanto(word: s)){
                ss2.append(s)
            }else{
                ss2 += preTokenizeJapanese(text: s)
            }
        }
        return ss2
    }
}

// ------------
//
// ------------

struct JaDictItemOfCodable : Codable{
    let key: String
    let values: [String]
    
    enum CodingKeys: String, CodingKey {
        case key = "k"
        case values = "v"
    }
}

struct DictItem : Codable{
    let rawKeyword: String
    let explanation: String
    let searchKeyword: String

    enum CodingKeys: String, CodingKey {
        case rawKeyword = "k"
        case explanation = "v"
        case searchKeyword = "s"
    }
}

struct SearchResponseItem{
    var lang: String                // "eo", "ja"
    var matchedKeyword: String
    var modifyKind: String
    var matchItems: [DictItem]
}

func nowTime() -> String { /* 19:33:32.265 */
    let format = DateFormatter()
    format.dateFormat = "mm:ss.SSS"
    return format.string(from: Date())
}

class LDictionary{
    private var dictItems = [String : DictItem]()
    private var jaDictItems = [String : [String]]()
    
    func initialize(){
print(nowTime(), "loading")

        initializeEoDict()
        initializeJaDict()
    }
    
    func initializeEoDict(){
print(nowTime(), "start eo")

        // ファイルまでのパスを取得（同時にnilチェック）
        if let path: String = Bundle.main.path(forResource: "dictionary00", ofType: "json") {
            do {
                // ファイルの内容を取得する
                let jsonData = try String(contentsOfFile: path)
                
                let decoder: JSONDecoder = JSONDecoder()
                do {
 print(nowTime(), "decode")

                    let ds : [DictItem] = try decoder.decode([DictItem].self, from: jsonData.data(using: .utf8)!)
print(nowTime(), "conv")

                    for dictItem in ds{
                        dictItems[dictItem.searchKeyword] = dictItem
                    }
                } catch {
                    print("error:", error.localizedDescription)
                }
                
            } catch  {
                print("ファイルの内容取得時に失敗")
            }
        }else {
            print("指定されたファイルが見つかりません")
        }
        
print(nowTime(), "end")
        print("loading EoDictionary end: ", dictItems.count, nowTime())
    }

    func initializeJaDict(){
print(nowTime(), "start ja")

        // ファイルまでのパスを取得（同時にnilチェック）
        if let path: String = Bundle.main.path(forResource: "JaDictionary00", ofType: "json") {
            do {
                // ファイルの内容を取得する
                let jsonData = try String(contentsOfFile: path)
                
                let decoder: JSONDecoder = JSONDecoder()
                do {
print(nowTime(), "decode")

                    let dictItemOfCodable: [JaDictItemOfCodable] = try decoder.decode([JaDictItemOfCodable].self, from: jsonData.data(using: .utf8)!)
                    //print(dictItems)
                    
print(nowTime(), "conv")

                    for i in dictItemOfCodable{
                        jaDictItems[i.key] = i.values
                    }
                } catch {
                    print("error:", error.localizedDescription)
                }
                
            } catch  {
                print("ファイルの内容取得時に失敗")
            }
            
            
        }else {
            print("指定されたファイルが見つかりません")
        }
        
print(nowTime(), "end")
        print("loading JaDictionary end: ", jaDictItems.count)
    }
    
    func sanitizeSearchKeywordEo(eoKeyword :String) -> String{
        return eoKeyword
            .lowercased()
            .removeCharacters(from: "/")
            .replacingOccurrences(of: "[,//._//?!]+", with: "", options: .regularExpression)
        // not remove "-" // prefikso, sufikso
    }
    
    func sanitizeSearchKeywordJa(jaKeyword :String) -> String{
        return jaKeyword
            .replacingOccurrences(of: "[？！。、]", with: "", options: .regularExpression)
            .replacingOccurrences(of: "//s", with: "", options: .regularExpression)
    }
    
    func searchEKeywordFullMatch(eoKeyword :String) -> DictItem?{
        let eoKeyword_ = sanitizeSearchKeywordEo(eoKeyword: eoKeyword)
        return dictItems[eoKeyword_]
    }
    
    func searchJaKeywordFullMatch(jaKeyword :String) -> [DictItem]{
        var dictItems :[DictItem] = []
        let jaKeyword_ = sanitizeSearchKeywordJa(jaKeyword: jaKeyword)
        let jaKeywords = jaDictItems[jaKeyword_] ?? []
        for jaKeyword in jaKeywords{
            let item = searchEKeywordFullMatch(eoKeyword: jaKeyword.replacingOccurrences(of: "/", with: "", options: .regularExpression))
            if(item != nil){
                dictItems.append(item!)
            }
        }
        return dictItems
    }
    
    func searchResponseFromKeywordFullMatch(keyword: String) -> SearchResponseItem{
        if(Esperanto.isEsperanto(word: keyword)){
            let match = searchEKeywordFullMatch(eoKeyword: keyword)
            if(match != nil){
                let matchItems = [match!] // 型ごまかし
                return SearchResponseItem(lang: "eo", matchedKeyword: keyword, modifyKind: "", matchItems: matchItems)
            }else{
                return SearchResponseItem(lang: "eo", matchedKeyword: keyword, modifyKind: "", matchItems: [])
            }
        }else{
            let matchItems = searchJaKeywordFullMatch(jaKeyword: keyword)
            return SearchResponseItem(lang: "ja", matchedKeyword: keyword, modifyKind: "", matchItems: matchItems)
        }
    }
    
    func searchResponseFromKeywordNearMatch(keyword_: String) -> SearchResponseItem{
        let keyword = keyword_.removeCharacters(from: "-")
        if(Esperanto.isEsperanto(word: keyword)){
            do{
                // prefikso "*-"
                let match = searchEKeywordFullMatch(eoKeyword: keyword + "-")
                if(match != nil){
                    let matchItems = [match!] // 型ごまかし
                    return SearchResponseItem(lang: "eo", matchedKeyword: keyword, modifyKind: "prefikso (*-)", matchItems: matchItems)
                }
            }
            do{
                // sufikso "-*-"
                let match = searchEKeywordFullMatch(eoKeyword: "-" + keyword + "-")
                if(match != nil){
                    let matchItems = [match!] // 型ごまかし
                    return SearchResponseItem(lang: "eo", matchedKeyword: keyword, modifyKind: "sufikso (-*-)", matchItems: matchItems)
                }
            }
            do{
                // sufikso "-*"
                let match = searchEKeywordFullMatch(eoKeyword: "-" + keyword)
                if(match != nil){
                    let matchItems = [match!] // 型ごまかし
                    return SearchResponseItem(lang: "eo", matchedKeyword: keyword, modifyKind: "sufikso (-*)", matchItems: matchItems)
                }
            }

            //
            for keyword_ in Esperanto.generateVerboCandidates(str: keyword){
                let match = searchEKeywordFullMatch(eoKeyword: keyword_)
                if(match != nil){
                    let matchItems = [match!] // 型ごまかし
                    return SearchResponseItem(lang: "eo", matchedKeyword: keyword, modifyKind: "verbo candidates", matchItems: matchItems)
                }
            }

            // mal-を除いたマッチ
            let unmal = keyword
                .lowercased().replacingOccurrences(of: "^mal", with: "", options: .regularExpression)
            if(unmal != keyword){
                let match = searchEKeywordFullMatch(eoKeyword: unmal)
                if(match != nil){
                    let matchItems = [match!] // 型ごまかし
                    return SearchResponseItem(lang: "eo", matchedKeyword: keyword, modifyKind: "mal- candidates", matchItems: matchItems)
                }

                for keyword_ in Esperanto.generateVerboCandidates(str: unmal){
                    let match = searchEKeywordFullMatch(eoKeyword: keyword_)
                    if(match != nil){
                        let matchItems = [match!] // 型ごまかし
                        return SearchResponseItem(lang: "eo", matchedKeyword: keyword, modifyKind: "mal- + verbo candidates", matchItems: matchItems)
                    }
                }
            }

            return SearchResponseItem(lang: "eo", matchedKeyword: keyword, modifyKind: "", matchItems: [])
        }else{
            return SearchResponseItem(lang: "ja", matchedKeyword: keyword, modifyKind: "", matchItems: [])
        }
    }
    
    func search(searchKey: String) -> [SearchResponseItem]{
        // ** searchKeyをクリンアップし分割
        let searchKey_ = Esperanto.convertCaretFromAnySistemo(str: searchKey)
        let searchWords = Tokenizer.tokenize(text: searchKey_)
        
        var result = [SearchResponseItem]()
        
        if(searchWords.count == 0){
            //result.append(SearchResponseItem(matchedKeyword: "", matchItem: nil))
            return result
        }
        
        // ** word全体とマッチ
        do{
            var fullSearchKey :String
            if(Esperanto.isEsperanto(word: searchWords[0])){
                fullSearchKey = searchWords.joined(separator: " ")
            }else{
                fullSearchKey = searchKey.replacingOccurrences(of: "//s", with: "", options: .regularExpression)
            }
            let response = searchResponseFromKeywordFullMatch(keyword: fullSearchKey)
            if(response.matchItems.count != 0){
                result.append(response)
                return result
            }
        }
        
        // 先頭から3wordずつマッチ
        var iSearchWord = 0
        while(iSearchWord < searchWords.count){
            // 3word 一致検索
            if(3 <= (searchWords.count - iSearchWord)){
                var is3Word = true;

                let is0 = Esperanto.isEsperanto(word: searchWords[iSearchWord])
                let is1 = Esperanto.isEsperanto(word: searchWords[iSearchWord + 1])
                let is2 = Esperanto.isEsperanto(word: searchWords[iSearchWord + 1])
                var joinedSearchKey = "";
                if(is0 && is1 && is2){ // eo
                    joinedSearchKey = searchWords[iSearchWord]
                        + " " + searchWords[iSearchWord + 1]
                        + " " + searchWords[iSearchWord + 2]
                }else if(!is0 && !is1 && !is2){ // ja
                    joinedSearchKey = searchWords[iSearchWord]
                        + "" + searchWords[iSearchWord + 1]
                        + "" + searchWords[iSearchWord + 2]
                }else{
                    is3Word = false;
                }
                
                if(is3Word){
                    let response = searchResponseFromKeywordFullMatch(keyword: joinedSearchKey)
                    if(response.matchItems.count != 0){
                        result.append(response)
                        iSearchWord += 3
                        continue
                    }
                }
            }
            // 2word 一致検索
            if(2 <= (searchWords.count - iSearchWord)){
                var is2Word = true;

                let is0 = Esperanto.isEsperanto(word: searchWords[iSearchWord])
                let is1 = Esperanto.isEsperanto(word: searchWords[iSearchWord + 1])
                var joinedSearchKey = "";
                if(is0 && is1){ // eo
                    joinedSearchKey = searchWords[iSearchWord] + " " + searchWords[iSearchWord + 1]
                }else if(!is0 && !is1){ // ja
                    joinedSearchKey = searchWords[iSearchWord] + "" + searchWords[iSearchWord + 1]
                }else{
                    is2Word = false;
                }
                
                if(is2Word){
                    let response = searchResponseFromKeywordFullMatch(keyword: joinedSearchKey)
                    if(response.matchItems.count != 0){
                        result.append(response)
                        iSearchWord += 2
                        continue
                    }
                }
            }
            //　1word 一致検索
            do{
                let keyStr :String = String(searchWords[iSearchWord])
                let response = searchResponseFromKeywordFullMatch(keyword: keyStr)
                if(response.matchItems.count != 0){
                    result.append(response)
                    iSearchWord += 1
                    continue
                }
            }
            
            // １1word 候補推定
            do{
                let keyStr :String = String(searchWords[iSearchWord])
                let response = searchResponseFromKeywordNearMatch(keyword_: keyStr)
                if(response.matchItems.count != 0){
                    result.append(response)
                    iSearchWord += 1
                    continue
                }
            }
            
            // マッチしなかった
            do{
                let searchKey1 :String = String(searchWords[iSearchWord])
                let lang = Esperanto.isEsperanto(word: searchKey1) ? "eo":"ja"
                result.append(SearchResponseItem(lang: lang, matchedKeyword: searchKey1, modifyKind: "", matchItems: []))
                iSearchWord += 1
                
            }
        }
        
        //print(searchWords, match)
        return result
    }
}
