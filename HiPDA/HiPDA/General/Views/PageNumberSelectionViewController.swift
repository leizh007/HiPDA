//
//  PageNumberSelectionViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/6.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

typealias PageNumberSelectedCompletion = (Int) -> Void

class PageNumberSelectionViewController: BaseViewController {
    var completion: PageNumberSelectedCompletion?
    var totalPageNumber = 1
    var updateSliderValue = true
    var currentPageNumber = 1 {
        didSet {
            if let label = pageNumberLabel {
                label.text = "\(currentPageNumber)"
            }
            if let slider = slider, updateSliderValue {
                slider.value = Float(currentPageNumber)
            }
        }
    }
    @IBOutlet fileprivate weak var pageNumberLabel: UILabel!
    @IBOutlet fileprivate weak var maxPageNumberLabel: UILabel!
    @IBOutlet fileprivate weak var slider: UISlider!
    override func viewDidLoad() {
        super.viewDidLoad()

        pageNumberLabel.text = "\(currentPageNumber)"
        maxPageNumberLabel.text = "\(totalPageNumber)"
        slider.maximumValue = Float(totalPageNumber)
        slider.value = Float(currentPageNumber)
    }
    
    @IBAction fileprivate func cancelButtonPressed(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction fileprivate func confirmButtonPressed(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
        completion?(currentPageNumber)
    }
    
    @IBAction fileprivate func firstPageButtonPressed(_ sender: UIButton) {
        updateSliderValue = true
        currentPageNumber = 1
    }
    
    @IBAction fileprivate func previousPageButtonPressed(_ sender: UIButton) {
        updateSliderValue = true
        currentPageNumber = currentPageNumber - 1 <= 0 ? 1 : currentPageNumber - 1
    }
    
    @IBAction fileprivate func nextPageButtonPressed(_ sender: UIButton) {
        updateSliderValue = true
        currentPageNumber = currentPageNumber + 1 > totalPageNumber ? currentPageNumber : currentPageNumber + 1
    }
    
    @IBAction fileprivate func lastPageButtonPressed(_ sender: UIButton) {
        updateSliderValue = true
        currentPageNumber = totalPageNumber
    }
    
    @IBAction fileprivate func sliderValueChanged(_ sender: UISlider) {
        updateSliderValue = false
        currentPageNumber = Int(round(sender.value))
    }
    
    @IBAction fileprivate func sliderDidFinishDragging(_ sender: UISlider) {
        updateSliderValue = true
        currentPageNumber = Int(round(sender.value))
    }
}

// MARK: - StoryboardLoadable

extension PageNumberSelectionViewController: StoryboardLoadable { }
