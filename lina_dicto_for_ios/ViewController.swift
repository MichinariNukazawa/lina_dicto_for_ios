//
//  ViewController.swift
//  test05
//
//  Created by Michinari Nukazawa on 2019/07/20.
//  Copyright © 2019 Michinari Nukazawa. All rights reserved.
//

import UIKit

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
    let pattern = "^[A-Za-z0-9\u{0108}-\u{016D}\\s^~.\\!\\?-]+$"
    return word.pregMatche(pattern: pattern)
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
    ]
    
    var dst = str
    for r in replaces{
        dst = dst.replacingOccurrences(of: r[1], with: r[0])
    }

    return dst
}

func convertAlfabetoFromAnySistemo(str :String) -> String{
    return convertAlfabetoFromCaretSistemo(str: convertCaretFromAnySistemo(str: str))
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
            if(isEsperanto(word: s)){
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

struct DictItemOfCodable : Codable{
    let key: String
    let value: String
}

struct JaDictItemOfCodable : Codable{
    let key: String
    let values: [String]
    
    enum CodingKeys: String, CodingKey {
        case key = "k"
        case values = "v"
    }
}

struct DictItem{
    let searchKeyword: String
    let rawKeyword: String
    let explanation: String
}

struct SearchResponseItem{
    var lang: String                // "eo", "ja"
    var matchedKeyword: String
    var matchItems: [DictItem]
}
class LDictionary{
    private var dictItems = [String : DictItem]()
    private var jaDictItems = [String : [String]]()

    func initialize(){
        initializeEoDict()
        initializeJaDict()
    }

    func initializeEoDict(){
        // ファイルまでのパスを取得（同時にnilチェック）
        if let path: String = Bundle.main.path(forResource: "dictionary00", ofType: "json") {
            do {
                // ファイルの内容を取得する
                let jsonData = try String(contentsOfFile: path)
                
                let decoder: JSONDecoder = JSONDecoder()
                do {
                    let dictItemOfCodable: [DictItemOfCodable] = try decoder.decode([DictItemOfCodable].self, from: jsonData.data(using: .utf8)!)
                    //print(dictItems)
                    
                    for i in dictItemOfCodable{
                        let searchKeyword = sanitizeSearchKeywordEo(eoKeyword: i.key)
                        let dictItem : DictItem = DictItem(searchKeyword: searchKeyword, rawKeyword: i.key, explanation: i.value)
                        dictItems[searchKeyword] = dictItem
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
    }
    
    func initializeJaDict(){
        // ファイルまでのパスを取得（同時にnilチェック）
        if let path: String = Bundle.main.path(forResource: "JaDictionary00", ofType: "json") {
            do {
                // ファイルの内容を取得する
                let jsonData = try String(contentsOfFile: path)
                
                let decoder: JSONDecoder = JSONDecoder()
                do {
                    let dictItemOfCodable: [JaDictItemOfCodable] = try decoder.decode([JaDictItemOfCodable].self, from: jsonData.data(using: .utf8)!)
                    //print(dictItems)
                    
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
        
        print("loading JaDictionary end: ", jaDictItems.count)
    }
    
    

    /*
    func initializeJaDict(){
        log(debug: "initialize dict ja: start")
        for (_, item) in dictItems{
            let meanWords = item.explanation.split(separator: ";")
            for meanWord_ in meanWords{
                var meanWord :String = String(meanWord_)
                meanWord = meanWord.replacingOccurrences(of: "{.+}", with: "", options: .regularExpression)        // 公認語根情報
                meanWord = meanWord.replacingOccurrences(of: "［.+］", with: "", options: .regularExpression)        // 文法情報(品詞情報)
                meanWord = meanWord.replacingOccurrences(of: "【.+】", with: "", options: .regularExpression)        // 専門用語の略号
                meanWord = meanWord.replacingOccurrences(of: "《.+》", with: "", options: .regularExpression)        // その他略記号
                
                // 後方を除去
                meanWord = meanWord.replacingOccurrences(of: "=.+$", with: "", options: .regularExpression)        // 同義語's
                meanWord = meanWord.replacingOccurrences(of: ">>.+$", with: "", options: .regularExpression)        // 関連語・類義語
                meanWord = meanWord.replacingOccurrences(of: "><.+$", with: "", options: .regularExpression)        // 反対語・対義語
                
                // 中を除去
                meanWord = meanWord.replacingOccurrences(of: "（[属科種]）", with: "", options: .regularExpression)        // 動植物名分類(属科種)
                
                let jaKeywords = meanWord.split(separator: ",")
                for jakeyword_ in jaKeywords{
                    var jaKeyword :String = String(jakeyword_)
                   // 先頭の括弧を除去
                    jaKeyword = jaKeyword
                        .replacingOccurrences(of: "（.+?）", with: "", options: .regularExpression)
                    jaKeyword = sanitizeSearchKeywordJa(jaKeyword: jaKeyword)
                    if(jaKeyword.count == 0){
                        continue;
                    }
                    var array :[DictItem] = jaDictItems[jaKeyword] ?? []
                    array.append(item)
                    jaDictItems[jaKeyword] = array
                }
            }
        }
        log(debug: "initialize dict ja: end")
    }
     */
    
    func sanitizeSearchKeywordEo(eoKeyword :String) -> String{
        return eoKeyword
            .lowercased()
            .removeCharacters(from: "/")
            .replacingOccurrences(of: "[,//._//?!-]+", with: "", options: .regularExpression)

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
        if(isEsperanto(word: keyword)){
            let match = searchEKeywordFullMatch(eoKeyword: keyword)
            if(match != nil){
                let matchItems = [match!] // 型ごまかし
                return SearchResponseItem(lang: "eo", matchedKeyword: keyword, matchItems: matchItems)
            }else{
                return SearchResponseItem(lang: "eo", matchedKeyword: keyword, matchItems: [])
            }
        }else{
            let matchItems = searchJaKeywordFullMatch(jaKeyword: keyword)
            return SearchResponseItem(lang: "ja", matchedKeyword: keyword, matchItems: matchItems)
        }
    }

    func search(searchKey: String) -> [SearchResponseItem]{
        // ** searchKeyをクリンアップし分割
        let searchKey_ = convertCaretFromAnySistemo(str: searchKey)
        let searchWords = Tokenizer.tokenize(text: searchKey_)
        
        var result = [SearchResponseItem]()
        
        if(searchWords.count == 0){
            //result.append(SearchResponseItem(matchedKeyword: "", matchItem: nil))
            return result
        }
        
        // ** word全体とマッチ
        do{
            var fullSearchKey :String
            if(isEsperanto(word: searchWords[0])){
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

        // 先頭から2wordずつマッチ
        var iSearchWord = 0
        while(iSearchWord < searchWords.count){
            // 2wordマッチ
            if(2 <= (searchWords.count - iSearchWord)){
                let joinedSearchKey :String = searchWords[iSearchWord] + " " + searchWords[iSearchWord + 1]

                let response = searchResponseFromKeywordFullMatch(keyword: joinedSearchKey)
                if(response.matchItems.count != 0){
                    result.append(response)
                    iSearchWord += 2
                    continue
                }
            }
            //　1word検索
            do{
                let keyStr :String = String(searchWords[iSearchWord])
                let response = searchResponseFromKeywordFullMatch(keyword: keyStr)
                if(response.matchItems.count != 0){
                    result.append(response)
                    iSearchWord += 1
                    continue
                }
            }
            do{
                // マッチしなかった
                let searchKey1 :String = String(searchWords[iSearchWord])
                let lang = isEsperanto(word: searchKey1) ? "eo":"ja"
                result.append(SearchResponseItem(lang: lang, matchedKeyword: searchKey1, matchItems: []))
                iSearchWord += 1

            }
        }
        
        //print(searchWords, match)
        return result
    }
}


// ------------
//
// ------------

class ViewController: UIViewController,  UISearchBarDelegate{
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var dict = LDictionary()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        searchBar.delegate = self

        dict.initialize()
        
        log()
    }
    
    func readText(filename: String, ext: String) -> String{
        // ファイルまでのパスを取得（同時にnilチェック）
        if let path: String = Bundle.main.path(forResource: filename, ofType: ext) {
            do {
                // ファイルの内容を取得する
                let txt = try String(contentsOfFile: path)
                return txt
            } catch  {
                print("ファイルの内容取得時に失敗")
            }
        }else {
            print("指定されたファイルが見つかりません")
        }

        return "nothing file error."
    }
    
    func command(str :String) -> Bool{
        if("!help" == str){
            let sHelp = "!help / このHelpを表示\n"
                + "!gvidilo / gvidilo.txtを表示\n"
                + "!legumin / legumin.txtを表示\n"
            textView.text = sHelp
            textView.scrollRangeToVisible(NSMakeRange(1, 1))
            return true
        }
        if("!gvidilo" == str){
            textView.text = "# gvidilo.txt\n"
            textView.text += readText(filename: "gvidilo", ext: "txt")
            textView.scrollRangeToVisible(NSMakeRange(1, 1))
            return true
        }
        if("!legumin" == str){
            textView.text = "# legumin.txt\n"
            textView.text += readText(filename: "legumin", ext: "txt")
            textView.scrollRangeToVisible(NSMakeRange(1, 1))
            return true
        }
        
        return false
    }
    
    //検索ボタン押下時の呼び出しメソッド
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        
        let searchKey = searchBar.text!
        
        
        let searchResponseItems = dict.search(searchKey: searchKey)
        if(searchResponseItems.count == 0){
            // NOP
            return
        }

        // コマンド処理
        if(command(str: searchKey)){
            searchBar.text = ""
            return
        }

        var html :String = ""
        do{
            let sSearchStyle = "style='font-size: 14px; background-color:rgba(128,256,128,0.6); width:100%'"
            let showSearchKey = searchKey.replacingOccurrences(of: "//s+", with: " ", options: .regularExpression)
            //showSearchKey = convertAlfabetoFromAnySistemo(str: showSearchKey)
            let t = "<div " + sSearchStyle + ">"
                + "＞" + showSearchKey + ""
                + "</div>"
            html += t
        }
        let sResponseStyle = "style='font-size: 22px'"
        for response in searchResponseItems{
            if(response.matchItems.count != 0){
                if(response.lang == "eo"){
                    let matchedKeyword :String = response.matchedKeyword
                    let explanation :String = response.matchItems[0].explanation
                    
                    let t = "<div " + sResponseStyle + ">"
                        + convertAlfabetoFromAnySistemo(str: matchedKeyword) + " : " + explanation
                        + "</div>"
                    html += t
                }else{
                    let matchedKeyword :String = response.matchedKeyword
                    var eoWords :[String] = []
                    for item in response.matchItems{
                        eoWords.append(convertAlfabetoFromAnySistemo(str: item.rawKeyword))
                    }
                    
                    let t = "<div " + sResponseStyle + ">"
                        + convertAlfabetoFromAnySistemo(str: matchedKeyword) + " : " + eoWords.joined(separator: ", ")
                        + "</div>"
                    html += t
                }
            }else{
                let matchedKeyword = response.matchedKeyword
                var src_lang = "eo"
                var dst_lang = "ja"
                if(!isEsperanto(word: matchedKeyword)){
                    src_lang = "ja"
                    dst_lang = "eo"
                }
                let url = generateGoogleTranslateUrl(keyword: matchedKeyword, src_lang: src_lang, dst_lang: dst_lang)
                html += "<div " + sResponseStyle + ">"
                    + convertAlfabetoFromAnySistemo(str: matchedKeyword)
                    + " : is not match."
                    + "<br>"
                    
                    + "<span style='font-size: 16px'>"
                    + "  (" + "<a href='" + url + "'>"
                    + "open browser google translate `"
                    + convertAlfabetoFromAnySistemo(str: matchedKeyword)
                    + "`"
                    + "</a>)<span>"
                    + "</div>"
            }
        }
        addHtmlForTextView(html: html)
        
        searchBar.text = ""
        scrollTextViewToBottom(textView: textView)
    }
    
    func addHtmlForTextView(html :String){
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

    
    // ------------
    //
    // ------------
    
    func scrollTextViewToBottom(textView: UITextView) {
        if textView.text.count > 0 {
            let location = textView.text.count - 1
            let bottom = NSMakeRange(location, 1)
            textView.scrollRangeToVisible(bottom)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // キーボードイベントの監視開始
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillBeShown(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillBeHidden(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // キーボードイベントの監視解除
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
    
    // キーボードが表示された時に呼ばれる
    @objc func keyboardWillBeShown(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue, let animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {
                restoreScrollViewSize()
                
                let convertedKeyboardFrame = scrollView.convert(keyboardFrame, from: nil)
                let dirtyMagickNumberPixel = 4 // iPad mini2 12.4実機で起こった被りを汚く対処
                // 本AppのsearchBarは画面下端なのできKeyboardだけ見ればOK。
                let offsetY: CGFloat = convertedKeyboardFrame.height + CGFloat(dirtyMagickNumberPixel)
                // https://qiita.com/takabosoft/items/51d33ec97970e4232cf0
                // -> iOS12では対応済みなのか（？）heightで正しく動作してる模様
                //let offsetY: CGFloat = UIScreen.main.bounds.height - convertedKeyboardFrame.minY
                if offsetY < 0 { return }
                updateScrollViewSize(moveSize: offsetY, duration: animationDuration)

                scrollTextViewToBottom(textView: textView)
            }
        }
    }
    
    // キーボードが閉じられた時に呼ばれる
    @objc func keyboardWillBeHidden(notification: NSNotification) {
        restoreScrollViewSize()
    }
    
    // moveSize分Y方向にスクロールさせる
    func updateScrollViewSize(moveSize: CGFloat, duration: TimeInterval) {
        UIView.beginAnimations("ResizeForKeyboard", context: nil)
        UIView.setAnimationDuration(duration)

        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: moveSize, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        UIView.commitAnimations()
    }
    
    func restoreScrollViewSize() {
        // キーボードが閉じられた時に、スクロールした分を戻す
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    
    // ------------
    //
    // ------------

    /// Storyboadでunwind sequeを引くために必要
    @IBAction func unwindToFirstView(segue: UIStoryboardSegue) {
    }

    // ------------
    //
    // ------------

}

