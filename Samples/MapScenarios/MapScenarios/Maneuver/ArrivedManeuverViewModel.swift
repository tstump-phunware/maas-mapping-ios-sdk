//
//  ArrivedManeuverViewModel.swift
//  MapScenarios
//
//  Created by Aaron Pendley on 10/24/19.
//  Copyright © 2019 Phunware. All rights reserved.
//

import Foundation
import UIKit

struct ArrivedManeuverViewModel {
    private let standardOptions: ManeuverTextOptions
    private let highlightOptions: ManeuverTextOptions
    
    private let destinationName: String?
    
    init(destinationName: String?,
        standardOptions: ManeuverTextOptions = .defaultStandardOptions,
         highlightOptions: ManeuverTextOptions = .defaultHighlightOptions) {
        self.destinationName = destinationName
        self.standardOptions = standardOptions
        self.highlightOptions = highlightOptions
    }
}

extension ArrivedManeuverViewModel: ManeuverViewModel {
    var attributedText: NSAttributedString {
        let templateString = NSLocalizedString("$0 at $1", comment: "$0 = 'You have arrived', $1 = destination name")
        let youHaveArrivedString = NSLocalizedString("You have arrived", comment: "")
        
        let attributed = NSMutableAttributedString(string: templateString, attributes: standardOptions.attributes)
        attributed.replace(substring: "$0", with: youHaveArrivedString, attributes: highlightOptions.attributes)
        attributed.replace(substring: "$1", with: destinationDisplayName, attributes: standardOptions.attributes)
        
        // Place a period at the end, using the same attributes as the last attributed substring.
        if let lastAttributes = attributed.lastAttributes {
            let period = NSAttributedString(string: ".", attributes: lastAttributes)
            attributed.append(period)
        }
        
        return attributed
    }
    
    var image: UIImage {
        return #imageLiteral(resourceName: "RouteListInstructionArrived")
    }
    
    private var destinationDisplayName: String {
        if let destinationName = destinationName {
            return destinationName
        } else {
            return NSLocalizedString("your destination", comment: "")
        }
    }
}