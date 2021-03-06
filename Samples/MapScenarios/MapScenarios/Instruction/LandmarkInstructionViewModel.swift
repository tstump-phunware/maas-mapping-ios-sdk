//
//  LandmarkInstructionViewModel.swift
//  MapScenarios
//
//  Created by Aaron Pendley on 10/18/19.
//  Copyright © 2019 Phunware. All rights reserved.
//

import Foundation
import UIKit
import PWMapKit

// MARK: - Notes
// LandmarkInstructionViewModel contains presentation logic for route instructions generated using the
// landmark routing feature. Straight/Turn instructions may contain one or more landmarks (though we're usually
// only interested in the last one). If a landmark is found, we can provide more detailed instructions
// (such as "Turn right in 10 feet at the Water Cooler"). If no landmark is found, we fall back to basic
// instruction text.

// MARK: - LandmarkInstructionViewModel
struct LandmarkInstructionViewModel {
    private let instruction: Instruction
    private let standardOptions: InstructionTextOptions
    private let highlightOptions: InstructionTextOptions
    
    private var minDistanceToUseLandmarkOnStraightInstruction: CLLocationDistance {
        // convert to meters
        return 50.0 / CLLocationDistance.feetPerMeter
    }
    
    init(for routeInstruction: PWRouteInstruction,
         standardOptions: InstructionTextOptions = .defaultStandardOptions,
         highlightOptions: InstructionTextOptions = .defaultHighlightOptions) {
        self.instruction = Instruction(for: routeInstruction)
        self.standardOptions = standardOptions
        self.highlightOptions = highlightOptions
    }
}

// MARK: InstructionViewModel conformance
extension LandmarkInstructionViewModel: InstructionViewModel {
    var image: UIImage {
        return image(for: instruction)
    }
    
    var attributedText: NSAttributedString {
        let attributed = baseAttributedText
        
        // For the last instruction, append a string indicating arrival.
        if let suffixTemplate = arrivalSuffixTemplate {
            let suffix = NSMutableAttributedString(string: suffixTemplate, attributes: standardOptions.attributes)
            suffix.replace(substring: "$0", with: destinationNameForRoute(containing: instruction), attributes: highlightOptions.attributes)
            attributed.append(suffix)
        }
        
        return attributed
    }
    
    var voicePrompt: String {
        var prompt = baseStringForVoicePrompt
        
        // For the last instruction, append a string indicating arrival.
        if let suffixTemplate = arrivalSuffixTemplate {
            let suffix = suffixTemplate.replacingOccurrences(of: "$0", with: destinationNameForRoute(containing: instruction))
            prompt = prompt + suffix
        }
        
        return prompt
    }
}

// MARK: - private
private extension LandmarkInstructionViewModel {
    
    var baseAttributedText: NSMutableAttributedString {
         let straightString = NSLocalizedString("Continue straight", comment: "")
         
         switch instruction.instructionType {
         case .straight:
            // If this instruction doesn't have a qualifying landmark, return basic text.
            guard let landmark = straightInstructionLandmark else {
                let templateString = NSLocalizedString("$0 for $1", comment: "$0 = Continue straight, $1 = distance")
                let attributed = NSMutableAttributedString(string: templateString, attributes: standardOptions.attributes)
                
                attributed.replace(substring: "$0", with: straightString, attributes: highlightOptions.attributes)
                
                let distanceString = instruction.routeInstruction.distance.localizedDistanceInSmallUnits
                attributed.replace(substring: "$1", with: distanceString, attributes: standardOptions.attributes)
                
                return attributed
            }

            // Use the landmark in the instruction text.
            let templateString = NSLocalizedString("$0 for $1, past the $2", comment: "$0 = Continue straight, $1 = distance, $2 = landmark")
            let attributed = NSMutableAttributedString(string: templateString, attributes: standardOptions.attributes)

            attributed.replace(substring: "$0", with: straightString, attributes: highlightOptions.attributes)

            let distanceString = instruction.routeInstruction.distance.localizedDistanceInSmallUnits
            attributed.replace(substring: "$1", with: distanceString, attributes: standardOptions.attributes)
            attributed.replace(substring: "$2", with: landmark.name, attributes: highlightOptions.attributes)

            return attributed
     
         case .turn(let direction):
            // Use the last landmark in the list (i.e. the one closest to the turn) if there are any landmarks. Otherwise, use basic text.
             if let landmark = instruction.routeInstruction.landmarks?.last {
                 let templateString = NSLocalizedString("$0 in $1 $2 $3", comment: "$0 = direction, $1 = distance, $2 = at/after, $3 = landmark name")
                 
                 let attributed = NSMutableAttributedString(string: templateString, attributes: standardOptions.attributes)
                 
                 let turnString = string(forTurn: direction) ?? ""
                 attributed.replace(substring: "$0", with: turnString, attributes: highlightOptions.attributes)
                 
                 let distanceString = instruction.routeInstruction.distance.localizedDistanceInSmallUnits
                 attributed.replace(substring: "$1", with: distanceString, attributes: standardOptions.attributes)
                 
                 attributed.replace(substring: "$2", with: landmark.localizedRelativePositionString, attributes: standardOptions.attributes)
                 attributed.replace(substring: "$3", with: landmark.name, attributes: highlightOptions.attributes)
                 
                 return attributed
                 
             } else {
                 let templateString = NSLocalizedString("$0 in $1", comment: "$0 = direction, $1 = distance")
                 let attributed = NSMutableAttributedString(string: templateString, attributes: standardOptions.attributes)
                 
                 let turnString = string(forTurn: direction) ?? ""
                 attributed.replace(substring: "$0", with: turnString, attributes: highlightOptions.attributes)
                 
                 let distanceString = instruction.routeInstruction.distance.localizedDistanceInSmallUnits
                 attributed.replace(substring: "$1", with: distanceString, attributes: standardOptions.attributes)
                 
                 return attributed
             }
             
         case .upcomingFloorChange(let floorChange):
             let templateString = NSLocalizedString("$0 $1 towards $2 to $3", comment: "$0 = Continue straight, $1 = distance, $2 floor change type, $3 = floor name")
             let attributed = NSMutableAttributedString(string: templateString, attributes: standardOptions.attributes)
             
             attributed.replace(substring: "$0", with: straightString, attributes: highlightOptions.attributes)
             
             let distanceString = instruction.routeInstruction.distance.localizedDistanceInSmallUnits
             attributed.replace(substring: "$1", with: distanceString, attributes: standardOptions.attributes)
             
             let floorChangeTypeString = string(for: floorChange.floorChangeType)
             attributed.replace(substring: "$2", with: floorChangeTypeString, attributes: highlightOptions.attributes)
             attributed.replace(substring: "$3", with: floorChange.floorName, attributes: highlightOptions.attributes)
             
             return attributed
             
         case .floorChange(let floorChange):
             let templateString = (floorChange.floorChangeDirection == .sameFloor)
                 ? NSLocalizedString("Take the $0 to $2", comment: "$0 = floor change type, $2 = floor name")
                 : NSLocalizedString("Take the $0 $1 to $2", comment: "$0 = floor change type, $1 = floor change direction, $2 = floor name")
             
             let attributed = NSMutableAttributedString(string: templateString, attributes: standardOptions.attributes)
             
             let floorChangeTypeString = string(for: floorChange.floorChangeType)
             attributed.replace(substring: "$0", with: floorChangeTypeString, attributes: highlightOptions.attributes)
             
             let directionString = string(forFloorChangeDirection: floorChange.floorChangeDirection) ?? ""
             attributed.replace(substring: "$1", with: directionString, attributes: standardOptions.attributes)
             attributed.replace(substring: "$2", with: floorChange.floorName, attributes: highlightOptions.attributes)
             
             return attributed
         }
     }
     
    var baseStringForVoicePrompt: String {
        let straightString = NSLocalizedString("Continue straight", comment: "")
        
        switch instruction.instructionType {
        case .straight:
            // If this instruction doesn't have a qualifying landmark, return basic text.
            guard let landmark = straightInstructionLandmark else {
                let templateString = NSLocalizedString("$0 for $1", comment: "$0 = Continue straight, $1 = distance")
                var prompt = templateString
                
                prompt = prompt.replacingOccurrences(of: "$0", with: straightString)
                
                let distanceString = instruction.routeInstruction.distance.localizedDistanceInSmallUnits
                prompt = prompt.replacingOccurrences(of: "$1", with: distanceString)
                
                return prompt
            }

            // Use the landmark in the instruction text.
            let templateString = NSLocalizedString("$0 for $1, past the $2", comment: "$0 = Continue straight, $1 = distance, $2 = landmark")
            var prompt = templateString
            
            prompt = prompt.replacingOccurrences(of: "$0", with: straightString)
            
            let distanceString = instruction.routeInstruction.distance.localizedDistanceInSmallUnits
            prompt = prompt.replacingOccurrences(of: "$1", with: distanceString)
            prompt = prompt.replacingOccurrences(of: "$2", with: landmark.name)
            
            return prompt

            
        case .turn(let direction):
            // Use the last landmark in the list (i.e. the one closest to the turn) if there are any landmarks. Otherwise, use basic text.
            if let landmark = instruction.routeInstruction.landmarks?.last {
                let templateString = NSLocalizedString("$0 for $1, then $2 $3 $4", comment: "$0 = Continue straight, $1 = distance, $2 = direction, $3 = at/after, $4 = landmark name")
                var prompt = templateString
                
                prompt = prompt.replacingOccurrences(of: "$0", with: straightString)
                
                let distanceString = instruction.routeInstruction.distance.localizedDistanceInSmallUnits
                prompt = prompt.replacingOccurrences(of: "$1", with: distanceString)
                
                let turnString = string(forTurn: direction)?.lowercased() ?? ""
                prompt = prompt.replacingOccurrences(of: "$2", with: turnString)
                
                prompt = prompt.replacingOccurrences(of: "$3", with: landmark.localizedRelativePositionString)
                prompt = prompt.replacingOccurrences(of: "$4", with: landmark.name)
                
                return prompt
            } else {
                let templateString = NSLocalizedString("$0 for $1, then $2", comment: "$0 = Continue straight, $1 = distance, $2 = direction")
                var prompt = templateString
                
                prompt = prompt.replacingOccurrences(of: "$0", with: straightString)
                
                let distanceString = instruction.routeInstruction.distance.localizedDistanceInSmallUnits
                prompt = prompt.replacingOccurrences(of: "$1", with: distanceString)
                
                let turnString = string(forTurn: direction)?.lowercased() ?? ""
                prompt = prompt.replacingOccurrences(of: "$2", with: turnString)
                
                return prompt
            }
            
        case .upcomingFloorChange(let floorChange):
            let templateString = NSLocalizedString("$0 $1 towards $2 to $3", comment: "$0 = Continue straight, $1 = distance, $2 floor change type, $3 = floor name")
            var prompt = templateString
            
            prompt = prompt.replacingOccurrences(of: "$0", with: straightString)
            
            let distanceString = instruction.routeInstruction.distance.localizedDistanceInSmallUnits
            prompt = prompt.replacingOccurrences(of: "$1", with: distanceString)
            
            let floorChangeTypeString = string(for: floorChange.floorChangeType)
            prompt = prompt.replacingOccurrences(of: "$2", with: floorChangeTypeString)
            prompt = prompt.replacingOccurrences(of: "$3", with: floorChange.floorName)
            
            return prompt
            
        case .floorChange(let floorChange):
            let templateString = (floorChange.floorChangeDirection == .sameFloor)
                ? NSLocalizedString("Take the $0 to $2", comment: "$0 = floor change type, $2 = floor name")
                : NSLocalizedString("Take the $0 $1 to $2", comment: "$0 = floor change type, $1 = floor change direction, $2 = floor name")
            
            var prompt = templateString
            
            let floorChangeTypeString = string(for: floorChange.floorChangeType)
            prompt = prompt.replacingOccurrences(of: "$0", with: floorChangeTypeString)
            
            let directionString = string(forFloorChangeDirection: floorChange.floorChangeDirection) ?? ""
            prompt = prompt.replacingOccurrences(of: "$1", with: directionString)
            prompt = prompt.replacingOccurrences(of: "$2", with: floorChange.floorName)
            
            return prompt
        }
    }
    
    var straightInstructionLandmark: PWLandmark? {
        // This is not a straight instruction, don't use it.
        guard instruction.isStraight else {
            return nil
        }
        
        // If the instruction's length isn't long enough for using a landmark to make sense, we won't use it.
        guard instruction.routeInstruction.distance >= minDistanceToUseLandmarkOnStraightInstruction else {
            return nil
        }
        
        // Return the last landmark, if there is one.
        return instruction.routeInstruction.landmarks?.last
    }
    
    // Return the template string used to generate the suffix text for the last instruction.
    var arrivalSuffixTemplate: String? {
        // This isn't the last instruction, so we don't want to append the arrival suffix
        guard instruction.isLast else {
            return nil
        }
        
        var suffixTemplate = " " + NSLocalizedString("to arrive at $0", comment: "$0 = destination name")
        
        // Special case: if there is a landmark on the last instruction, append a comma
        // before appending the arrival suffix to make it look/sound more natural.
        if straightInstructionLandmark != nil {
            suffixTemplate = "," + suffixTemplate
        }
        
        return suffixTemplate
    }
}

private extension PWLandmark {
    var localizedRelativePositionString: String {
        guard position == .at else {
            return NSLocalizedString("after", comment: "")
        }
        
        // Use "near" for associated landmarks at the turn
        if landmarkType == .associatedLandmark {
            return NSLocalizedString("near", comment: "")
        } else {
            return NSLocalizedString("at", comment: "")
        }
    }
}
