//
//  ViewController.swift
//  test05
//
//  Created by Michinari Nukazawa on 2019/07/20.
//  Copyright © 2019 Michinari Nukazawa. All rights reserved.
//

import UIKit


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
    return link;
}


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

// esperantoワードか（含む文字かチェック）
func isEsperanto(word :String) -> Bool {
    // 厳密なマッチではないけれど、日本語と区別できればOK
    let pattern = "^[A-Za-z0-9 \\s^~\u{0108}-\u{016D}]+$"
    return word.pregMatche(pattern: pattern);
}

func convertCaretFromAnySistemo(str :String) -> String{
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
    ];
    
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
    return res;
}

func convertAlfabetoFromCaretSistemo(str :String) -> String{
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
    ];
    
    var dst = str
    for r in replaces{
        dst = dst.replacingOccurrences(of: r[1], with: r[0])
    }

    return dst;
}

func convertAlfabetoFromAnySistemo(str :String) -> String{
    return convertAlfabetoFromCaretSistemo(str: convertCaretFromAnySistemo(str: str))
}

struct DictItem : Codable{
    let key: String
    let value: String
}
struct SearchResponseItem{
    var matchedKey: String
    var matchItem: DictItem?
}
class LDictionary{
    private var dictItems = [DictItem]()
    
    func initialize(){
        // ファイルまでのパスを取得（同時にnilチェック）
        if let path: String = Bundle.main.path(forResource: "dictionary00", ofType: "json") {
            do {
                // ファイルの内容を取得する
                let jsonData = try String(contentsOfFile: path)
                
                let decoder: JSONDecoder = JSONDecoder()
                do {
                    let dictItems_: [DictItem] = try decoder.decode([DictItem].self, from: jsonData.data(using: .utf8)!)
                    //print(dictItems)
                    dictItems = dictItems_
                    
                } catch {
                    print("error:", error.localizedDescription)
                }
                
            } catch  {
                print("ファイルの内容取得時に失敗")
            }
            
            
        }else {
            print("指定されたファイルが見つかりません")
        }
        
    }
    
    func searchEKeywordFullMatch(eKeyword :String) -> DictItem?{
        var match :DictItem? = nil
        let casedSearchKey = eKeyword.lowercased()
        var count :Int = 0
        for dictItem in dictItems{
            var itemKey : String = dictItem.key.lowercased()
            itemKey = itemKey.removeCharacters(from: "/")
            if(itemKey == casedSearchKey){
                match = dictItem;
                break
            }
            count += 1
        }
        return match
    
    }

    func search(searchKey: String) -> [SearchResponseItem]{
        let searchKey_ = convertCaretFromAnySistemo(str: searchKey)
        let searchWords = searchKey_.replacingOccurrences(of: "//s+", with: " ", options: .regularExpression).split(separator: " ")
        
        let fullSearchKey = searchWords.joined(separator: " ")
        
        let match = searchEKeywordFullMatch(eKeyword: fullSearchKey);
        //print(searchWords, match)
        var result = [SearchResponseItem]()
        let resultItem = SearchResponseItem(matchedKey: searchKey, matchItem: match)
        print(resultItem)
        result.append(resultItem)
        return result
    }
}

class ViewController: UIViewController,  UISearchBarDelegate{
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var textView: UITextView!
    
    var dict = LDictionary()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        searchBar.delegate = self

        dict.initialize()
    }
    
    //検索ボタン押下時の呼び出しメソッド
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        
        let searchKey = searchBar.text!
        
        
        let result = dict.search(searchKey: searchKey)
        var match :DictItem? = nil
        if(0 < result.count){
            match = result[0].matchItem
        }

        if("(result area)" == textView.text){ // 最初の表示をクリア
            textView.text = "";
        }

        let sStyle = "style='font-size: 20px'"
        var html = ""
        if(match != nil){
            let key :String = match?.key ?? ""
            let value :String = match?.value ?? ""
            
            html = "<div " + sStyle + ">" + convertAlfabetoFromCaretSistemo(str: key) + " : " + value + "</div>"
        }else{
            var src_lang = "eo"
            var dst_lang = "ja"
            if(!isEsperanto(word: searchKey)){
                src_lang = "ja"
                dst_lang = "eo"
            }
            let url = generateGoogleTranslateUrl(keyword: searchKey, src_lang: src_lang, dst_lang: dst_lang)
            html = "<div " + sStyle + ">" + " not match : <a href='" + url + "'>"
                + convertAlfabetoFromAnySistemo(str: searchKey)
                + "</a>" + "</div>"
        }
        do{
            
            let encoded = html.data(using: String.Encoding.utf8)!
            let attributedOptions : [NSAttributedString.DocumentReadingOptionKey : Any] = [
                .documentType : NSAttributedString.DocumentType.html,
                .characterEncoding : String.Encoding.utf8.rawValue
            ]
            let attributedTxt = try! NSAttributedString(data: encoded,
                                                        options: attributedOptions,
                                                        documentAttributes: nil)

            let t :NSAttributedString = textView.attributedText!
            let tNsmStr = NSMutableAttributedString()
            tNsmStr.append(t)
            tNsmStr.append(attributedTxt)
            textView.attributedText = tNsmStr
        }
        
        searchBar.text = ""
    }
}

