//
//  StatisticsViewController.swift
//  Calculator
//
//  Created by Bernhard Kraft on 11.08.15.
//  Copyright (c) 2015 bfk engineering. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!{
        didSet {
            textView.text = text
        }
    }

    var text:String?{
        didSet {textView?.text = text}
    }
    
    override var preferredContentSize:CGSize {
        get{
            if textView != nil && presentingViewController != nil{
                textView.sizeToFit()
                return textView.sizeThatFits(presentingViewController!.view.bounds.size)
            }
            else{
                return super.preferredContentSize
            }
        }
        set{
            super.preferredContentSize = newValue
        }
    }
}
