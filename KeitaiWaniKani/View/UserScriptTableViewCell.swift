//
//  UserScriptTableViewCell.swift
//  KeitaiWaniKani
//
//  Copyright © 2015 Chris Laverty. All rights reserved.
//

import UIKit

class UserScriptTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    var settingName: String? {
        didSet { settingNameLabel.text = settingName }
    }
    
    var settingDescription: String? {
        didSet { settingDescriptionLabel.text = settingDescription }
    }
    
    var applicationSettingKey: String? {
        didSet {
            if let applicationSettingKey = applicationSettingKey {
                toggleSwitch.enabled = true
                toggleSwitch.on = ApplicationSettings.userDefaults.boolForKey(applicationSettingKey)
            } else {
                toggleSwitch.enabled = false
                toggleSwitch.on = false
            }
        }
    }
    
    // MARK: Outlets
    
    @IBOutlet weak var settingNameLabel: UILabel!
    @IBOutlet weak var settingDescriptionLabel: UILabel!
    @IBOutlet weak var toggleSwitch: UISwitch!
    @IBOutlet weak var nameToDescriptionLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionHeightConstraint: NSLayoutConstraint!
    
    // MARK: Actions
    
    @IBAction func toggleSwitch(sender: UISwitch) {
        guard let applicationSettingKey = applicationSettingKey else { return }
        ApplicationSettings.userDefaults.setBool(sender.on, forKey: applicationSettingKey)
    }
    
    func toggleDescriptionVisibility() {
        if descriptionHeightConstraint.constant == 0 {
            nameToDescriptionLayoutConstraint.constant = 8
            descriptionHeightConstraint.constant = 1000
            settingDescriptionLabel.alpha = 1
        } else {
            nameToDescriptionLayoutConstraint.constant = 0
            descriptionHeightConstraint.constant = 0
            settingDescriptionLabel.alpha = 0
        }
        contentView.setNeedsUpdateConstraints()
    }
    
    func setToDefault() {
        settingDescriptionLabel.alpha = 0
        nameToDescriptionLayoutConstraint.constant = 0
        descriptionHeightConstraint.constant = 0
        contentView.setNeedsUpdateConstraints()
    }
    
}
