//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by Shiv Sakhuja on 6/23/17.
//  Copyright © 2017 Shiv Sakhuja. All rights reserved.
//

import UIKit
import Messages

struct Language {
    
    var name:String = ""
    var code:String = ""
    var icon:String = ""
    
}


class LanguagePickerCell: UICollectionViewCell {
    
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
    
    
    func setupNameLabel() {
        nameLabel = UILabel(frame: CGRect(
            x:40,
            y:10,
            width:70,
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
            width:25,
            height:30
        ))
        iconLabel.text = "😀"
        contentView.addSubview(iconLabel)
    }
}

class MessagesViewController: MSMessagesAppViewController, UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {
    
    private let cellReuseIdentifier = "LanguagePickerCell"
    private let languageList = [
        Language(name:"English",
                 code: "en",
                 icon: ""),
        Language(name:"French",
                 code: "fr",
                 icon: ""),
        Language(name:"Spanish",
                 code: "es",
                 icon: ""),
        Language(name:"Hindi",
                 code: "hi",
                 icon: ""),
        Language(name:"Italian",
                 code: "it",
                 icon: ""),
        Language(name:"German",
                 code: "ge",
                 icon: ""),
        Language(name:"Russian",
                 code: "ru",
                 icon: ""),
        
    ]
    
    private var selectedLanguage: Language = Language(name:"English", code: "en", icon: "")
    
    // UI
    private var textView:UITextView = UITextView.init()
    private var languagePickerBackgroundView:UIView = UIView.init()
    private var languagePickerCollectionView:UICollectionView = UICollectionView.init(frame: CGRect(
        x: 0,
        y: 0,
        width: 200,
        height: 200
    ), collectionViewLayout: UICollectionViewLayout.init())
    private var doneButton:UIButton = UIButton.init()
    private var sendButton:UIButton = UIButton.init()
    private var languageSelectButton:UIButton = UIButton.init()
    private var containerView: UIView = UIView.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        checkInternet()
        setupView()
        
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
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // cell for item
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! LanguagePickerCell
        
        let language = languageList[indexPath.row % languageList.count]
        cell.nameLabel.text = language.name
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
        setupDoneButton()
        setupLanguageSelectButton()
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
            width: 30,
            height: 30
        ))
        languageSelectButton.setTitle("en", for: .normal)
        languageSelectButton.backgroundColor = UIColor.blue.withAlphaComponent(0.4);
        languageSelectButton.layer.cornerRadius = 4
        languageSelectButton.addTarget(self, action: #selector(showLanguagePicker), for: .touchUpInside)
        containerView.addSubview(languageSelectButton)
        
    }
    
    func setupLanguagePickerCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        layout.itemSize = CGSize(width: 120, height: 50)
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
        languagePickerCollectionView.tintColor = UIColor.white
        languagePickerCollectionView.isUserInteractionEnabled = true
        languagePickerCollectionView.delegate = self
        languagePickerCollectionView.dataSource = self
        languagePickerBackgroundView.addSubview(languagePickerCollectionView)
    }

    func setupLanguagePickerBackgroundView() {
        languagePickerBackgroundView = UIPickerView(frame: CGRect(
            x:0,
            y:0,
            width: containerView.frame.size.width,
            height: 300
        ))
        languagePickerBackgroundView.backgroundColor = UIColor.black
        containerView.addSubview(languagePickerBackgroundView)
    }
    
    func setupDoneButton() {
        doneButton = UIButton(frame: CGRect(
            x: 10,
            y: 20,
            width: containerView.frame.size.width - 20,
            height: 50
        ))
        doneButton.backgroundColor = UIColor.purple.withAlphaComponent(0.4)
        doneButton.layer.cornerRadius = 5.0
        doneButton.setTitle("Done", for: .normal)
        doneButton.isHidden = true
        doneButton.addTarget(self, action:#selector(doneButtonPressed), for: .touchUpInside)
        
        containerView.addSubview(doneButton)
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
            height: 150))
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
    
    func setupDoneButtonGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(doneButtonPressed(_:)))
        tap.delegate = self
        doneButton.addGestureRecognizer(tap)
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
        print(TranslateApi.init().translate(string: stringToTranslate, targetLanguage: "fr", onSuccess: {(translatedText) -> Void in
                self.composeMessage(text: translatedText)
                print(" \n\n\n translated text is:\n \(translatedText)")
        }, onFailure: {(error) -> Void in
                print(" \n\n\n error occurred:\n \(error)")
            }))
    }
    
    func willSwitchToCompactView() {
        print("\n\n\ncompacting\n\n\n")
        
        // adjust text field
        adjustTextView(pres: .compact)
        
        // show language to button
        
        
        // hide done button
        doneButton.isHidden = true
        
        // show send button
        sendButton.isHidden = false
        
        // show language select button
        languageSelectButton.isHidden = false
    }
    
    func willSwitchToExpandedView() {
        print("\n\n\nexpanding\n\n\n")
        
        // adjust text field
        adjustTextView(pres: .expanded)
        
        // hide language to button and picker
        hideLanguagePicker()
        
        // show done button
        doneButton.isHidden = false
        
        // show send button
        sendButton.isHidden = true
        
        // hide language select button
        languageSelectButton.isHidden = true
    }
    
    
    func didSwitchToExpandedView() {
        //modify containerView
        adjustContainerView(pres: .expanded)
        textView.isEditable = true
    }
    
    func didSwitchToCompactView() {
        adjustContainerView(pres: .compact)
        textView.isEditable = false
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
                height: 120
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
