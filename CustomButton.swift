//
//  CustomButton.swift
//  iBeacon App
//
//  Created by Randy McLain on 5/12/16.
//  Copyright © 2016 Randy McLain. All rights reserved.
//

import UIKit

@IBDesignable
class CustomButton: UIButton {
  @IBInspectable var cornerRadius: CGFloat = 0 {
    didSet {
      layer.cornerRadius = cornerRadius
      layer.masksToBounds = cornerRadius > 0
    }
  }
  @IBInspectable var borderWidth: CGFloat = 0 {
    didSet {
      layer.borderWidth = borderWidth
    }
  }
  @IBInspectable var borderColor: UIColor? {
    didSet {
      layer.borderColor = borderColor?.cgColor
    }
  }
}

