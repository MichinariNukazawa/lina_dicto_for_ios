//
//  ViewController.swift
//  test05
//
//  Created by Michinari Nukazawa on 2019/07/20.
//  Copyright © 2019 Michinari Nukazawa. All rights reserved.
//

import UIKit

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
            //showSearchKey = Esperanto.convertAlfabetoFromAnySistemo(str: showSearchKey)
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

                    if("" == response.modifyKind){
                        let t = "<div " + sResponseStyle + ">"
                            + Esperanto.convertAlfabetoFromAnySistemo(str: matchedKeyword) + " : " + explanation
                            + "</div>"
                        html += t
                    }else{
                        let sModifyStule = "style='font-size: 14px'"
                        let t = "<div " + sResponseStyle + ">"
                            + "<span " + sModifyStule + ">"
                            + Esperanto.convertAlfabetoFromAnySistemo(str: matchedKeyword)
                            + " → " + "</span>" + response.matchItems[0].rawKeyword
                            + " : " + explanation
                            + "</div>"
                        html += t
                    }
                }else{
                    let matchedKeyword :String = response.matchedKeyword
                    var eoWords :[String] = []
                    for item in response.matchItems{
                        eoWords.append(Esperanto.convertAlfabetoFromAnySistemo(str: item.rawKeyword))
                    }
                    
                    let t = "<div " + sResponseStyle + ">"
                        + Esperanto.convertAlfabetoFromAnySistemo(str: matchedKeyword) + " : " + eoWords.joined(separator: ", ")
                        + "</div>"
                    html += t
                }
            }else{
                let matchedKeyword = response.matchedKeyword
                var src_lang = "eo"
                var dst_lang = "ja"
                if(!Esperanto.isEsperanto(word: matchedKeyword)){
                    src_lang = "ja"
                    dst_lang = "eo"
                }
                let url = generateGoogleTranslateUrl(keyword: matchedKeyword, src_lang: src_lang, dst_lang: dst_lang)
                html += "<div " + sResponseStyle + ">"
                    + Esperanto.convertAlfabetoFromAnySistemo(str: matchedKeyword)
                    + " : is not match."
                    + "<br>"
                    
                    + "<span style='font-size: 16px'>"
                    + "  (" + "<a href='" + url + "'>"
                    + "open browser google translate `"
                    + Esperanto.convertAlfabetoFromAnySistemo(str: matchedKeyword)
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

