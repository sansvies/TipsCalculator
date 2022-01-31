//
//  ViewController.swift
//  TipsDraft
//
//  Created by Alex Son on 28.01.22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var billInput: UITextField!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalPartyLabel: UILabel!
    @IBOutlet weak var partyLabel: UILabel!
    @IBOutlet weak var totalView: UIView!
    @IBOutlet weak var totalPersonView: UIView!
    
    @IBOutlet weak var tipSelect: UISegmentedControl!
    @IBOutlet weak var partyStepper: UIStepper!

    // NumberFormatter() Форматировщик, преобразующий числовые значения в их текстовые представления. Это мощный способ легко форматировать числа в строки
    let currencyFormatter = NumberFormatter()
    // Save data with User Defaults
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure currency formatter
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current;

        reset()
        billInput.text = Locale.current.currencySymbol
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("view will appear")
        
        // Default tipping & tax options
        UserDefaults.standard.register(defaults: ["tipOption0" : 10])
        UserDefaults.standard.register(defaults: ["tipOption1" : 15])
        UserDefaults.standard.register(defaults: ["tipOption2" : 18])
      //  UserDefaults.standard.register(defaults: ["tipOption3" : 20])
    // UserDefaults.standard.register(defaults: ["salesTax" : 6])
        
        // Set segmented control tipping options
        tipSelect.setTitle(defaults.string(forKey: "tipOption0")! + "%", forSegmentAt: 0)
        tipSelect.setTitle(defaults.string(forKey: "tipOption1")! + "%", forSegmentAt: 1)
        tipSelect.setTitle(defaults.string(forKey: "tipOption2")! + "%", forSegmentAt: 2)
     //   tipSelect.setTitle(defaults.string(forKey: "tipOption3")! + "%", forSegmentAt: 3)
        
        // Retrieve saved input if less than 10 minutes ago
        let lastTime = defaults.double(forKey: "lastTime")
        if (Date().timeIntervalSince1970 - lastTime < 600) {
            billInput.text = defaults.string(forKey: "bill")
            partyStepper.value = defaults.double(forKey: "partySize")
            tipSelect.selectedSegmentIndex = defaults.integer(forKey: "tipIndex")
        } else {
            /* Select bill input when app opens. This wipes its input, so this only
               happens when previous input isn't loaded */
            billInput.becomeFirstResponder()
        }
        
        // Calculate tip
        calc(true)
    }

    /**
        Calculate tip, total, and splot payment per person in party
     */
    @IBAction func calc(_ sender: Any) {
        
        // Get bill and party size values
        let bill = Double(billInput.text!) ?? 0
        let partySize = partyStepper.value
        
        // Array of tipping increments in order they appear in segmented controls
        // converted to decimal format
        let tipAmounts = [defaults.double(forKey: "tipOption0")/100,
                          defaults.double(forKey: "tipOption1")/100,
                          defaults.double(forKey: "tipOption2")/100]
                      
        
        // Tip calculation
        let tip = bill * tipAmounts[tipSelect.selectedSegmentIndex]

        // Tax calculation
        let tax = bill * defaults.double(forKey: "salesTax")/100
        
        // Total calculation (bill + tip + tax)
        let total = bill + tip + tax
        
        // Total Per Person calculation (total / party size)
        let totalParty = total / partySize
        
        // Set outputs to calculated values
        totalLabel.text = currencyFormatter.string(from: NSNumber(value: total))!
        totalPartyLabel.text = currencyFormatter.string(from: NSNumber(value: totalParty))!
        partyLabel.text = String(format:"%.0f", partySize)
        
        // Save inputs
        defaults.set(bill, forKey: "bill")
        defaults.set(partySize, forKey: "partySize")
        defaults.set(tipSelect.selectedSegmentIndex, forKey: "tipIndex")
        defaults.set(Date().timeIntervalSince1970, forKey: "lastTime")
        defaults.synchronize()
        
    }
    
    /**
        When bill input selected, wipe previous input and resest all calcuated outputs
     */
    @IBAction func editBillBegin(_ sender: Any) {
        billInput.text = ""
        reset()
    }
    
    /**
        When bill input was edited but left empty, reset to default value
     */
    @IBAction func editBillEnd(_ sender: Any) {
        if(billInput.text == "") {
            billInput.text = Locale.current.currencySymbol
        }
    }
    
    /**
        Close keyboard when tapped anywhere on View
     */
    @IBAction func onTap(_ sender: Any) {
        view.endEditing(true)
    }
    
    /**
        Set all inputs and calculated outputs to zero
     */
    func reset() {
        totalLabel.text = currencyFormatter.string(from: NSNumber(value: 0))!
        totalPartyLabel.text = currencyFormatter.string(from: NSNumber(value: 0))!
    }
    
}
