//
//  PatientInfoTextFieldView.swift
//
//  Created by Developer on 3/7/18.
//

import Foundation

enum PatientInfoTextFieldViewType : Int {
    case patientID
    case firstName
    case lastName
    case country
    case addressLine1
    case addressLine2
    case city
    case state
    case zip
    case monthBirth
    case dayBirth
    case yearBirth
}

protocol PatientInfoTextFiledViewDelegate : class {
    func textFieldShouldReturn(withTextField textField : UITextField)
    func updatedRequiredTextField(textField : UITextField, insertedMinimumRequiredText:Bool)
}

class PatientInfoTextFieldView : UIView {
    //IBOutlets
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var arrowIconImageView: UIImageView!
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var infoTextField: UITextField!
    @IBOutlet var view : UIView!
    //Constraints
    @IBOutlet weak var arrowButtonWidthConstraint: NSLayoutConstraint!
    
    var delegate : PatientInfoTextFiledViewDelegate?
    fileprivate var typePicker:UIPickerView?
    fileprivate var typeFields = ["State 1", "State 2", "State 3"]
    fileprivate var leadingBarButtonGroups = Array<UIBarButtonItemGroup>()
    fileprivate var trailingBarButtonGroups = Array<UIBarButtonItemGroup>()
    fileprivate var selectedPickerRow = 0
    
    //MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNIB()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNIB()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private var isActiveIndicatorView : Bool = false {
        didSet {
            indicatorView.isHidden = !isActiveIndicatorView
        }
    }
    
    private var isActiveArrowButton : Bool = false {
        didSet {
            arrowButton.isHidden = !isActiveArrowButton
            arrowButtonWidthConstraint.constant = isActiveArrowButton ? 50 : 0
            arrowIconImageView.isHidden = arrowButton.isHidden
            arrowIconImageView.changeTintColor(withColor: UIColor.color_B3B3B3)
        }
    }
    
    var textFieldTypeInt : Int = 0 {
        didSet {
            
            if let tempType = PatientInfoTextFieldViewType(rawValue: textFieldTypeInt) {
                textFieldTypeInt = tempType.rawValue
                
                if textFieldTypeInt == PatientInfoTextFieldViewType.patientID.rawValue {
                    infoLabel.text = NSLocalizedString("Patient ID    **From your EHR/EMR", comment: "")
                    infoLabel.attributedText = getTitleAttributedText(mainText: infoLabel.text!, titleText: "**From your EHR/EMR", color: UIColor.white, font: UIFont(name: Fonts.sfuiDisplayRegular.rawValue, size: 14)!)
                }else if textFieldTypeInt == PatientInfoTextFieldViewType.firstName.rawValue {
                    infoLabel.text = NSLocalizedString("First Name", comment: "")
                    isActiveIndicatorView = true
                } else if textFieldTypeInt == PatientInfoTextFieldViewType.lastName.rawValue {
                    infoLabel.text = NSLocalizedString("Last Name", comment: "")
                    isActiveIndicatorView = true
                }else if textFieldTypeInt == PatientInfoTextFieldViewType.country.rawValue {
                    infoLabel.text = ""
                    infoTextField.placeholder = NSLocalizedString("United States", comment: "")
                    infoTextField.attributedPlaceholder = getTitleAttributedText(mainText: "United States", titleText: "United States", color: UIColor.white, font: UIFont(name: Fonts.sfproTextSemibold.rawValue, size: 16)!)
                    isActiveArrowButton = true
                } else if textFieldTypeInt == PatientInfoTextFieldViewType.addressLine1.rawValue {
                    infoLabel.text = NSLocalizedString("Address Line 1", comment: "")
                } else if textFieldTypeInt == PatientInfoTextFieldViewType.addressLine2.rawValue {
                    infoLabel.text = NSLocalizedString("Address Line 2", comment: "")
                } else if textFieldTypeInt == PatientInfoTextFieldViewType.city.rawValue {
                    infoLabel.text = NSLocalizedString("City", comment: "")
                } else if textFieldTypeInt == PatientInfoTextFieldViewType.state.rawValue {
                    infoLabel.text = ""
                    infoTextField.placeholder = NSLocalizedString("Select State", comment: "")
                    infoTextField.attributedPlaceholder = getTitleAttributedText(mainText: "Select State", titleText: "Select State", color: UIColor.white, font: UIFont(name: Fonts.sfuiDisplaySemibold.rawValue, size: 16)!)
                    isActiveArrowButton = true
                }else if textFieldTypeInt == PatientInfoTextFieldViewType.zip.rawValue {
                    infoLabel.text = NSLocalizedString("Zip", comment: "")
                    infoTextField.keyboardType = .numberPad
                    infoTextField.returnKeyType = .done
                }
            }
        }
    }
    
    //MARK: - Private
    fileprivate func loadNIB() {
        Bundle.main.loadNibNamed("\(type(of: self))", owner: self, options: nil)
        addConstraints(withView: view)
        activeKeyboard()
        configureContent()
    }
    
    fileprivate func configureContent() {
        infoTextField.delegate = self
        let inputAssistantItem = infoTextField.inputAssistantItem
        leadingBarButtonGroups = inputAssistantItem.leadingBarButtonGroups
        trailingBarButtonGroups = inputAssistantItem.trailingBarButtonGroups
        showBarButtonGroups(show: false)
    }
    
    fileprivate func getTitleAttributedText(mainText:String, titleText:String, color:UIColor, font:UIFont) -> NSAttributedString {
        let range = (mainText as NSString).range(of: titleText)
        let attribute = NSMutableAttributedString(string: mainText)
        attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: color , range: range)
        attribute.addAttribute(NSAttributedStringKey.font, value: font, range: range)
        return attribute
    }
    
    fileprivate func getTypePicker() -> UIPickerView {
        let picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 150))
        picker.dataSource = self
        picker.delegate = self
        picker.showsSelectionIndicator = true
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.selectRow(selectedPickerRow, inComponent: 0, animated: true)
        typePicker = picker
        return picker
    }
    
    fileprivate func getToolbar() -> UIToolbar {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        let cancelButton = getBarItem(title: "Cancel", action: #selector(typePickerCancelButtonDidPressed))
        let doneButton = getBarItem(title: "Done", action: #selector(typePickerDoneButtonDidPressed))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.items = [cancelButton, flexibleSpace, doneButton]
        return toolBar
    }
    
    fileprivate func getBarItem(title:String, action: Selector?) ->UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.addTarget(self, action: action!, for: .touchUpInside)
        button.tag = tag
        let barItem = UIBarButtonItem(customView: button)
        return barItem
    }
    
    fileprivate func updatePicker(savePickerText:Bool) {
        if let picker = typePicker {
            if savePickerText {
                infoTextField.text = typeFields[picker.selectedRow(inComponent: 0)]
            }else {
               infoTextField.text = nil
            }
            selectedPickerRow = picker.selectedRow(inComponent: 0)
            delegate?.textFieldShouldReturn(withTextField: infoTextField)
        }
    }
    
    private func containsOnlyCharactersIn(matchCharacters: String, mainText: String) -> Bool {
        let disallowedCharacterSet = CharacterSet(charactersIn: matchCharacters).inverted
        return mainText.rangeOfCharacter(from: disallowedCharacterSet) == nil
    }
    
    @objc fileprivate func typePickerCancelButtonDidPressed() {
        updatePicker(savePickerText: false)
    }
    
    @objc fileprivate func typePickerDoneButtonDidPressed() {
        updatePicker(savePickerText: true)
    }
    
    //MARK: - IBActions
    @IBAction func arrowButtonDidPressed(_ sender: UIButton) {
        infoTextField.becomeFirstResponder()
    }
}

//MARK: - Delegates
//MARK: - UITextFieldDelegate
extension PatientInfoTextFieldView : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textFieldTypeInt == PatientInfoTextFieldViewType.country.rawValue ||
            textFieldTypeInt == PatientInfoTextFieldViewType.state.rawValue  {
            infoTextField.inputView = getTypePicker()
            infoTextField.inputAccessoryView = getToolbar()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        //Need to update the shortcut bar
        showBarButtonGroups(show: false)
        delegate?.textFieldShouldReturn(withTextField: textField)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textFieldTypeInt ==  PatientInfoTextFieldViewType.firstName.rawValue ||  textFieldTypeInt ==  PatientInfoTextFieldViewType.lastName.rawValue {
            var insertedMinimumRequiredText = !string.isEmpty
            var currentText : NSString = ""
            if !insertedMinimumRequiredText {
                if let textFieldText = textField.text {
                    currentText = textFieldText as NSString
                }
                let newText = currentText.replacingCharacters(in: range, with: string)
                insertedMinimumRequiredText = !newText.isEmpty
            }
            delegate?.updatedRequiredTextField(textField: textField, insertedMinimumRequiredText: insertedMinimumRequiredText)
        }
        
        if textFieldTypeInt == PatientInfoTextFieldViewType.country.rawValue ||
        textFieldTypeInt == PatientInfoTextFieldViewType.state.rawValue  {
            return false
        }
        
        if textFieldTypeInt ==  PatientInfoTextFieldViewType.zip.rawValue {
            var currentText : NSString = ""
            if let textFieldText = textField.text {
                currentText = textFieldText as NSString
            }
            let prospectiveText = currentText.replacingCharacters(in: range, with: string)
            if !containsOnlyCharactersIn(matchCharacters: "0123456789", mainText: prospectiveText) {
                return false
            }
        }
        
        return true
    }
}

//MARK: - UIPickerViewDataSource/UIPickerViewDelegate
extension PatientInfoTextFieldView : UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return typeFields.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       return typeFields[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let picker = typePicker {
            infoTextField.text = typeFields[picker.selectedRow(inComponent: 0)]
        }
    }
}

//MARK: Keyboard extensions
extension PatientInfoTextFieldView {
    //MARK: - Keyboard Control
    func activeKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //Mark: - Keyboard Calls
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            //Need to update the shortcut bar
            showBarButtonGroups(show: keyboardSize.height > 55)
        }
    }
    
    @objc func keyboardWillHide (_ notification: Notification) {
        //Need to update the shortcut bar
        showBarButtonGroups(show: false)
    }
    
    fileprivate func showBarButtonGroups(show:Bool) {
        if show {
            //Need to show shortcut bar
            let inputAssistantItem = infoTextField.inputAssistantItem
            if inputAssistantItem.leadingBarButtonGroups != leadingBarButtonGroups {
                inputAssistantItem.leadingBarButtonGroups = leadingBarButtonGroups
            }
            
            if inputAssistantItem.trailingBarButtonGroups != trailingBarButtonGroups {
                inputAssistantItem.trailingBarButtonGroups = trailingBarButtonGroups
            }
        } else {
            //Need to hide shortcut bar if keyboard is active with ⇧+⌘+K combinations
            let inputAssistantItem = infoTextField.inputAssistantItem
            inputAssistantItem.leadingBarButtonGroups = []
            inputAssistantItem.trailingBarButtonGroups = []
        }
        infoTextField.layoutIfNeeded()
    }
}
