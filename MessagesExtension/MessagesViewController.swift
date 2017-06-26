//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by Shiv Sakhuja on 6/23/17.
//  Copyright © 2017 Shiv Sakhuja. All rights reserved.
//

import UIKit
import Messages
import Smile

extension Dictionary {
    init(_ pairs: [Element]) {
        self.init()
        for (k, v) in pairs {
            self[k] = v
        }
    }
}

struct Language {
    
    var name:String = ""
    var code:String = ""
    var icon:String?
    
}


class LanguagePickerCell: UICollectionViewCell {
    
    let colors = [
        UIColor(colorLiteralRed: 0.2, green: 0.6, blue: 0.9, alpha: 1).withAlphaComponent(0.7),
        UIColor(colorLiteralRed: 0.2, green: 1, blue: 0.7, alpha: 1).withAlphaComponent(0.7),
        UIColor.green.withAlphaComponent(0.7),
        UIColor.red.withAlphaComponent(0.6),
        UIColor.yellow.withAlphaComponent(0.6),
        UIColor.orange.withAlphaComponent(0.6),
        UIColor.white.withAlphaComponent(0.6)
    ]
    
    var iconLabel: UILabel = UILabel()
    var nameLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupNameLabel()
        setupIconLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getRandomColor() -> UIColor {

        return colors[Int(arc4random_uniform(UInt32(colors.count)))]
    }
    
    
    func setupNameLabel() {
        nameLabel = UILabel(frame: CGRect(
            x:50,
            y:10,
            width:self.frame.size.width - 50,
            height:30
        ))
        nameLabel.font = UIFont(name: "HelveticaNeue", size: 16)
        nameLabel.textColor = UIColor.white
        nameLabel.text = ""
        contentView.addSubview(nameLabel)
    }
    
    func setupIconLabel() {
        iconLabel = UILabel(frame: CGRect(
            x:10,
            y:10,
            width:30,
            height:30
        ))
        let color = getRandomColor()
        iconLabel.text = ""
        iconLabel.font = UIFont(name: "HelveticaNeue", size: 14)
        iconLabel.textAlignment = .center
        iconLabel.textColor = color
        iconLabel.layer.cornerRadius = iconLabel.frame.size.width/2
        iconLabel.layer.borderColor = color.cgColor
        iconLabel.layer.borderWidth = 1
        contentView.addSubview(iconLabel)
    }
}

class MessagesViewController: MSMessagesAppViewController, UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {
    
    private let BUTTON_HEIGHT = 50
    private let cellReuseIdentifier = "LanguagePickerCell"
    private var languageList: [Language] = []
    private var selectedLanguage: Language = Language(name:"English", code: "en", icon: "")
    
    // UI
    private var textView:UITextView = UITextView.init()
    private var languagePickerBackgroundView:UIView = UIView.init()
    private var languagePickerCollectionView:UICollectionView = UICollectionView.init(frame: CGRect(
        x: 0,
        y: 0,
        width: 200,
        height: 120
    ), collectionViewLayout: UICollectionViewLayout.init())
    private var doneButton:UIButton = UIButton.init()
    private var clearButton:UIButton = UIButton.init()
    private var translatingToInfoLabel:UILabel = UILabel.init()
    private var languageSelectButton:UIButton = UIButton.init()
    private var containerView: UIView = UIView.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setAllowedLanguages()
        checkInternet()
        setupView()
        
    }
    
    func setAllowedLanguages() {
        if let languages = readLanguagesJson() {
            languageList = languages.sorted(by: { $0.name < $1.name })
        } else {
            logError(error: "Could not get list of languages from languages.json")
        }
    }
    
    private func readLanguagesJson() -> [Language]? {
        do {
            if let file = Bundle.main.url(forResource: "languages", withExtension: "json") {
                var languages:[Language] = []
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [String: String] {
                    for key in object.keys {
                        if let languageName = object[key] {
                            let lang = Language(name:languageName, code:key, icon:self.getFirstCharacter(str: languageName))
                            languages.append(lang)
                        }
                    }
                    return languages
                }
                else {
                    print("JSON is invalid")
                }
            } else {
                print("languages.json file not found")
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    func getIconFromCode(code:String) -> String {
        let smileEmoji = Smile.emoji(countryCode: code)
        
        if (code == "hi") {
            print("smile emoji for hindi is \(smileEmoji)")
        }
        if (smileEmoji.characters.count == 1) {
            return smileEmoji
        }
        else if (smileEmoji.characters.count == 2) {
            let index = smileEmoji.index(smileEmoji.startIndex, offsetBy: 1)
            return smileEmoji.substring(to: index)
        }
        else {
            switch code {
            case "en":
                // English
                return Smile.emoji(countryCode: "us")
            case "hi":
                // Hindi
                return Smile.emoji(countryCode: "in")
            case "el":
                // Greek
                return Smile.emoji(countryCode: "gr")
            case "haw":
                // Hawaian
                return Smile.emoji(countryCode: "us")
            default:
                return "😁"
            }
        }
    }
    
    func getFirstCharacter(str:String) -> String {
        let index = str.index(str.startIndex, offsetBy: 1)
        return str.substring(to: index)
    }
    
    func checkInternet() {
        do {
            Network.reachability = try Reachability(hostname: "https://www.google.com")
            do {
                try Network.reachability?.start()
            } catch let error as Network.Error {
                print("error 1 is \(error)")
            } catch {
                print("error 2 is \(error)")
            }
        } catch {
            print("error is 3 \(error)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        
        // Use this method to configure the extension and restore previously stored state.
    }
    
    
    // Collection View stuff
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // selected item
        print("\n\n\nselected item at index \(indexPath.row)\n\n\n")
        selectedLanguage = languageList[indexPath.row]
        hideLanguagePicker()
        updateLanguageSelected()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // cell for item
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! LanguagePickerCell
        let language = languageList[indexPath.row % languageList.count]
        
        cell.nameLabel.text = language.name
        cell.iconLabel.text = language.icon
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        cell.layer.cornerRadius = 6
        cell.layer.masksToBounds = true
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return languageList.count
    }
    
    
    func setupView() {
        setupContainerView()
        setupTextView()
        setupClearButton()
        setupDoneButton()
        setupLanguageSelectButton()
        setupTranslatingToInfoLabel()
        setupLanguagePickerBackgroundView()
        setupLanguagePickerCollectionView()
        
        //
        hideLanguagePicker()
        setupTextViewGestureRecognizer()
    }
    
    func setupContainerView() {
        containerView = UIView(frame: view.frame)
        view.addSubview(containerView)
    }
    
    func setupLanguageSelectButton() {
        languageSelectButton = UIButton.init(frame: CGRect(
            x:10,
            y:10,
            width: 40,
            height: 30
        ))
        languageSelectButton.setTitle("\(selectedLanguage.code)", for: .normal)
        languageSelectButton.backgroundColor = UIColor.blue.withAlphaComponent(0.4);
        languageSelectButton.layer.cornerRadius = 4
        languageSelectButton.addTarget(self, action: #selector(showLanguagePicker), for: .touchUpInside)
        containerView.addSubview(languageSelectButton)
        
    }
    
    func updateLanguageSelected() {
        languageSelectButton.setTitle(selectedLanguage.code, for: .normal)
        setAttributedInfoString()
    }
    
    func setupLanguagePickerCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 150, height: 50)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        languagePickerCollectionView = UICollectionView(frame: CGRect(
            x:10,
            y:10,
            width: languagePickerBackgroundView.frame.size.width - 20,
            height: languagePickerBackgroundView.frame.size.height
        ), collectionViewLayout: layout)
        languagePickerCollectionView.register(LanguagePickerCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        languagePickerCollectionView.backgroundColor = UIColor.black
        languagePickerCollectionView.layer.cornerRadius = 5
        languagePickerCollectionView.tintColor = UIColor.white
        languagePickerCollectionView.isScrollEnabled = true
        languagePickerCollectionView.alwaysBounceVertical = true
        languagePickerCollectionView.isUserInteractionEnabled = true
        languagePickerCollectionView.delegate = self
        languagePickerCollectionView.dataSource = self
        languagePickerBackgroundView.addSubview(languagePickerCollectionView)
    }

    func setupLanguagePickerBackgroundView() {
        languagePickerBackgroundView = UIView(frame: CGRect(
            x:0,
            y:0,
            width: containerView.frame.size.width,
            height: 200
        ))
        languagePickerBackgroundView.backgroundColor = UIColor.clear
        containerView.addSubview(languagePickerBackgroundView)
    }
    
    func setupTranslatingToInfoLabel() {
        translatingToInfoLabel = UILabel(frame:
            CGRect(
                x:60,
                y: 10,
                width:containerView.frame.size.width - 20,
                height:30
            )
        )
        
        translatingToInfoLabel.textColor = UIColor.lightGray
        translatingToInfoLabel.font = UIFont(name: "HelveticaNeue", size: 12.0)
        // create attributed string
        setAttributedInfoString()
        translatingToInfoLabel.isHidden = false
        containerView.addSubview(translatingToInfoLabel)
    }
    
    func setAttributedInfoString() {
        let infoString = "translating to \(selectedLanguage.name)"
        let range = NSRange(location: infoString.characters.count - selectedLanguage.name.characters.count, length: selectedLanguage.name.characters.count)
        let myMutableString = NSMutableAttributedString(string: infoString, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 13.0)!])
        myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blue.withAlphaComponent(0.5), range: range)
        // set label Attribute
        translatingToInfoLabel.attributedText = myMutableString
    }
    
    func setupDoneButton() {
        doneButton = UIButton(frame: CGRect(
            x: (containerView.frame.size.width + 5)/2,
            y: 20,
            width: (containerView.frame.size.width - 20)/2,
            height: 50
        ))
        doneButton.backgroundColor = UIColor.blue.withAlphaComponent(0.6)
        doneButton.layer.cornerRadius = 5.0
        doneButton.setTitle("Done", for: .normal)
        doneButton.isHidden = true
        doneButton.addTarget(self, action:#selector(doneButtonPressed), for: .touchUpInside)
        
        containerView.addSubview(doneButton)
    }
    
    func setupClearButton() {
        clearButton = UIButton(frame: CGRect(
            x: 15/2,
            y: 20,
            width: (containerView.frame.size.width - 20)/2,
            height: 50
        ))
        clearButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
        clearButton.layer.cornerRadius = 5.0
        clearButton.setTitle("Clear", for: .normal)
        clearButton.isHidden = true
        clearButton.addTarget(self, action:#selector(clearButtonPressed), for: .touchUpInside)
        
        containerView.addSubview(clearButton)
    }
    
    func clearButtonPressed() {
        textView.text = ""
    }
    
    func hideLanguagePicker() {
        languagePickerBackgroundView.isHidden = true
    }
    
    func showLanguagePicker() {
        languagePickerBackgroundView.isHidden = false
    }
    
    func setupTextView() {
        textView = UITextView(frame: CGRect(
            x:10,
            y:50,
            width:containerView.frame.size.width - 20,
            height: 100))
        textView.font = UIFont(name: "HelveticaNeue-Light", size: 18.0)
        textView.textColor = UIColor.black.withAlphaComponent(0.65)
        textView.backgroundColor = UIColor.black.withAlphaComponent(0.08)
        textView.layer.cornerRadius = 6.0
        textView.tag = 99 // dummy
        textView.isEditable = false
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        textView.delegate = self
        containerView.addSubview(textView)
    }
    
    func setupTextViewGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(expandView(_:)))
        tap.delegate = self
        textView.addGestureRecognizer(tap)
    }
    
    func expandView(_ sender:AnyObject) {
        self.requestPresentationStyle(.expanded)
    }
    
    func doneButtonPressed(_ sender:AnyObject) {
        print("donebutton was pressed")
        fetchTranslation(stringToTranslate:textView.text)
        self.requestPresentationStyle(.compact)
    }
    
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
        
        switch presentationStyle {
            case .compact:
                willSwitchToCompactView()
            case .expanded:
                willSwitchToExpandedView()
        }
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
        if (presentationStyle == .expanded) {
            self.didSwitchToExpandedView()
        } else {
            self.didSwitchToCompactView()
        }
        
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }
    
    private func composeMessage(text:String) {
        let conversation = activeConversation
        conversation?.insertText("\(text)", completionHandler: {
            error in
            if let err = error {
                self.logError(error: "Could not insert text into your conversation. \(String(describing: err))")
            } else {
                print("Success!")
            }
        })
    }
    
    func fetchTranslation(stringToTranslate:String) {
        print(TranslateApi.init().translate(string: stringToTranslate, targetLanguage: "\(selectedLanguage.code)", onSuccess: {(translatedText) -> Void in
                self.composeMessage(text: translatedText)
                print(" \n\n\n translated text is:\n \(translatedText)")
        }, onFailure: {(error) -> Void in
                print(" \n\n\n error occurred:\n \(error)")
            }))
    }
    
    func willSwitchToCompactView() {
        
        
        // hide done button
        doneButton.isHidden = true
        clearButton.isHidden = true
        
        // show language select button
        languageSelectButton.isHidden = false
    }
    
    func willSwitchToExpandedView() {
        
        // hide language to button and picker
        hideLanguagePicker()
        
        // show done button
        doneButton.isHidden = false
        clearButton.isHidden = false
        
        // hide language select button
        languageSelectButton.isHidden = true
    }
    
    
    func didSwitchToExpandedView() {
        adjustContainerView(pres: .expanded)
        adjustTextView(pres: .expanded)
        adjustTranslatingToInfoLabel(pres: .expanded)
        textView.isEditable = true
    }
    
    func didSwitchToCompactView() {
        adjustContainerView(pres: .compact)
        adjustTextView(pres: .compact)
        adjustTranslatingToInfoLabel(pres: .compact)
        textView.isEditable = false
    }
    
    func adjustTranslatingToInfoLabel(pres: MSMessagesAppPresentationStyle) {
        if (pres == .compact) {
            translatingToInfoLabel.isHidden = false
            translatingToInfoLabel.frame = CGRect(
                x:60,
                y: 10,
                width:containerView.frame.size.width - 20,
                height:30
            )
        }
        else {
            translatingToInfoLabel.isHidden = false
            translatingToInfoLabel.frame = CGRect(
                x:10,
                y: textView.frame.origin.y + textView.frame.size.height + 10,
                width:containerView.frame.size.width - 20,
                height:30
            )
        }
    }
    
    func adjustContainerView(pres: MSMessagesAppPresentationStyle) {
        if (pres == .compact) {
            containerView.frame = view.frame
        }
        else {
            containerView.frame = CGRect(
                x:0,
                y:100,
                width:view.frame.size.width,
                height:view.frame.size.height - 100
            )
        }
    }
    
    func adjustTextView(pres: MSMessagesAppPresentationStyle) {
        if (pres == .compact) {
            // compact
            textView.frame = CGRect(
                x:10,
                y:50,
                width:containerView.frame.size.width - 20,
                height: 100
            )
            
        } else {
            // expanded
            textView.frame = CGRect(
                x:10,
                y:80,
                width:containerView.frame.size.width - 20,
                height: 200
            )
        }
    }
    
    func logError(error: String) {
        print("oops \(error)")
    }

}
