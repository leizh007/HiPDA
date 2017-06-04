//
//  PostOperationViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/4.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

private enum Constant {
    static let animationDuration = 0.25
    enum OperationButtonSize {
        static let width = CGFloat(44.0)
        static let height = CGFloat(44.0)
    }
    static let buttonRightMargin = CGFloat(16.0)
    static let buttonTopMargin = CGFloat(20.0)
}

enum PostOperation: Int {
    case collection
    case attention
    case top
    case bottom
}

protocol PostOperationDelegate: class {
    func operationCancelled()
    func didSelected(_ operation: PostOperation)
}

class PostOperationButton: UIButton {
    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            if newValue {
                backgroundColor = #colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 1)
            } else {
                backgroundColor = .white
            }
            super.isHighlighted = newValue
        }
    }
}

class PostOperationViewController: UIViewController {
    weak var delegate: PostOperationDelegate?
    
    @IBOutlet var operationButtons: [PostOperationButton]!
    override func viewDidLoad() {
        super.viewDidLoad()
        operationButtons.forEach { addShadow(to: $0) }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = .clear
        operationButtons.forEach { button in
            button.frame = CGRect(x: C.UI.screenWidth - Constant.buttonRightMargin - Constant.OperationButtonSize.width, y: C.UI.statusBarHeight, width: Constant.OperationButtonSize.width, height: Constant.OperationButtonSize.height)
            button.alpha = 0.3
        }
        UIView.animate(withDuration: Constant.animationDuration) {
            self.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3)
            self.operationButtons.forEach { $0.alpha = 1.0 }
        }
        showButtons(from: 0)
    }
    
    func display(in parentViewController: UIViewController, frame: CGRect) {
        parentViewController.addChildViewController(self)
        view.frame = frame
        parentViewController.view.addSubview(view)
        didMove(toParentViewController: parentViewController)
    }
    
    func dismiss() {
        hideButtons(from: operationButtons.count - 1)
        UIView.animate(withDuration: Constant.animationDuration) {
            self.view.backgroundColor = .clear
            self.operationButtons.forEach { $0.alpha = 0.3 }
        }
    }
    
    @IBAction fileprivate func cancelButtonPressed(_ sender: UIButton) {
        delegate?.operationCancelled()
    }
    
    @IBAction func operationButtonPressed(_ sender: PostOperationButton) {
        guard let operation = PostOperation(rawValue: sender.tag) else { return }
        delegate?.didSelected(operation)
    }
}

// MARK: - Button Move Animation

extension PostOperationViewController {
    fileprivate func showButtons(from index: Int) {
        guard let button = operationButtons.safe[index] else { return }
        var frame = button.frame
        frame.origin.y += (index == 0 ? 40.0 : Constant.buttonTopMargin) + Constant.OperationButtonSize.height
        UIView.animate(withDuration: Constant.animationDuration / Double(operationButtons.count), animations: {
            for i in index..<self.operationButtons.count {
                self.operationButtons.safe[i]?.frame = frame
            }
        }, completion: { _ in
            self.showButtons(from: index + 1)
        })
    }
    
    fileprivate func hideButtons(from index: Int) {
        guard let button = operationButtons.safe[index] else {
            willMove(toParentViewController: nil)
            view.removeFromSuperview()
            removeFromParentViewController()
            return
        }
        var frame = button.frame
        frame.origin.y -= (index == 0 ? 40.0 : Constant.buttonTopMargin) + Constant.OperationButtonSize.height
        UIView.animate(withDuration: Constant.animationDuration / Double(operationButtons.count), animations: {
            for i in index..<self.operationButtons.count {
                self.operationButtons.safe[i]?.frame = frame
            }
        }, completion: { _ in
            self.hideButtons(from: index - 1)
        })
    }
}

// MARK: - StoryboardLoadable

extension PostOperationViewController: StoryboardLoadable { }

// MARK: - Utils

fileprivate func addShadow(to view: UIView) {
    let shadowSize = CGFloat(6.0)
    let width = Constant.OperationButtonSize.width
    let height = Constant.OperationButtonSize.height
    let shadowPath = UIBezierPath(roundedRect: CGRect(x: -shadowSize / 2.0,
                                                      y: -shadowSize / 2.0,
                                                      width: width + shadowSize,
                                                      height: height + shadowSize),
                                  cornerRadius: (shadowSize + width) / 2.0)
    view.layer.masksToBounds = false
    view.layer.shadowColor = UIColor.darkGray.cgColor
    view.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    view.layer.shadowOpacity = 0.5
    view.layer.shadowPath = shadowPath.cgPath
}
