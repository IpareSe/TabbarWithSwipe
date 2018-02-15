//
//  STDTabbar.swift
//  TopTab
//
//  Created by Paresh Prajapati on 15/02/18.
//  Copyright © 2018 Paresh Prajapati. All rights reserved.
//

import UIKit

protocol CustomTabBarDataSource {
    func tabBarItemsInCustomTabBar(tabBarView: CustomTabBar) -> [UITabBarItem]
}

protocol CustomTabBarDelegate {
    func didSelectViewController(tabBarView: CustomTabBar, atIndex index: Int)
}

class STDTabbar: UITabBarController, CustomTabBarDataSource, CustomTabBarDelegate {
    @IBOutlet weak var tabCust: UITabBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tabOne = ViewController(nibName: "ViewController", bundle: nil)
        let tabOneBarItem = UITabBarItem(title: "Tab 1", image: #imageLiteral(resourceName: "1"), selectedImage: #imageLiteral(resourceName: "2"))
        tabOne.tabBarItem = tabOneBarItem
        
        
        // Create Tab two
        let tabTwo = ViewController1()
        let tabTwoBarItem2 = UITabBarItem(title: "Tab 2", image:#imageLiteral(resourceName: "2"), selectedImage: #imageLiteral(resourceName: "3"))
        
        tabTwo.tabBarItem = tabTwoBarItem2
        
        
        self.viewControllers = [tabOne, tabTwo]
        self.tabBar.isHidden = true
        let customTabBar = CustomTabBar(frame: self.tabBar.frame, SuperV:self)
        customTabBar.datasource = self
        customTabBar.delegate = self
        customTabBar.setup()
        
        self.view.addSubview(customTabBar)
        // Do any additional setup after loading the view.
    }
    
    
    // MARK: - CustomTabBarDataSource
    
    func tabBarItemsInCustomTabBar(tabBarView: CustomTabBar) -> [UITabBarItem] {
        return self.tabBar.items!
    }
    
    // MARK: - CustomTabBarDelegate
    
    func didSelectViewController(tabBarView: CustomTabBar, atIndex index: Int) {
        self.selectedIndex = index
    }


}

class CustomTabBar: UIView {
    
    var datasource: CustomTabBarDataSource!
    var delegate: CustomTabBarDelegate!
    var tababarVC: UITabBarController?
    var tabBarItems: [UITabBarItem]!
    var customTabBarItems: [CustomTabBarItem]!
    var tabBarButtons: [UIButton]!
    var Sliderview : UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init(frame: CGRect, SuperV:UITabBarController) {
        
        super.init(frame: frame)
        self.tababarVC = SuperV
        self.backgroundColor = UIColor.white
    }
    
    func setup() {
        // get tab bar items from default tab bar
        tabBarItems = datasource.tabBarItemsInCustomTabBar(tabBarView: self)
        
        customTabBarItems = []
        tabBarButtons = []
        
        let containers = createTabBarItemContainers()
        createTabBarItems(containers: containers)
        self.addGestureForswipe()
        self.setSlideView()
    }
    
    func createTabBarItems(containers: [CGRect]) {
        
        var index = 0
        for item in tabBarItems {
            
            let container = containers[index]
            
            let customTabBarItem = CustomTabBarItem(frame: container)
            customTabBarItem.setup(item: item)
            
            self.addSubview(customTabBarItem)
            customTabBarItems.append(customTabBarItem)
            
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: container.width, height: container.height))
            button.addTarget(self, action: #selector(barItemTapped), for: UIControlEvents.touchUpInside)
            
            customTabBarItem.addSubview(button)
            tabBarButtons.append(button)
            
            index += 1
        }
    }
    
    func createTabBarItemContainers() -> [CGRect] {
        
        var containerArray = [CGRect]()
        
        // create container for each tab bar item
        for index in 0..<tabBarItems.count {
            let tabBarContainer = createTabBarContainer(index: index)
            containerArray.append(tabBarContainer)
        }
        
        return containerArray
    }
    
    func createTabBarContainer(index: Int) -> CGRect {
        
        let tabBarContainerWidth = self.frame.width / CGFloat(tabBarItems.count)
        let tabBarContainerRect = CGRect(x: tabBarContainerWidth * CGFloat(index), y: 0, width: tabBarContainerWidth, height: self.frame.height)
        
        return tabBarContainerRect
    }
    
    func setSlideView()
    {
        var Frame = self.customTabBarItems[0].frame
        Frame.size.height = 3.0
        Sliderview = UIView(frame: Frame)
        Sliderview.backgroundColor = UIColor.red
        self.addSubview(Sliderview)
    }
    
    func Swipe(at:Int, side:String) {
        UIView.animate(withDuration: 0.5, animations: {
            var Frame = self.Sliderview.frame
            let selected = self.customTabBarItems[at].frame
            if side == "Right"
            {
                Frame.origin.x = selected.origin.x
            }
            else{
                Frame.origin.x = selected.origin.x
                
            }
            self.Sliderview.frame = Frame
            self.layoutSubviews()
            
        }) { (finish) in
            
        }
    }
    
    func addGestureForswipe()
    {
        
        let swipeleft = UISwipeGestureRecognizer(target: self, action: #selector(gestureLeft))
        swipeleft.direction = .left
        self.tababarVC?.view.addGestureRecognizer(swipeleft)
        let swiperight = UISwipeGestureRecognizer(target: self, action: #selector(gestureRight))
        swiperight.direction = .right
        
        self.tababarVC?.view.addGestureRecognizer(swiperight)
    }
    
    @objc func gestureLeft()
    {
        let selectedindex = self.tababarVC?.selectedIndex ?? 0
        let total = self.customTabBarItems.count
        if selectedindex == total - 1
        {
            return
        }
        let index = selectedindex + 1
        self.customTabBarItems.forEach { (customtab) in
            customtab.backgroundColor = UIColor.white
        }
        self.customTabBarItems[index].backgroundColor = UIColor.green
        delegate.didSelectViewController(tabBarView: self, atIndex: index)
        self.Swipe(at: index, side: "Left")
    }
    
    @objc func gestureRight()
    {
        let selectedindex = self.tababarVC?.selectedIndex ?? 0
        if selectedindex <= 0
        {
            return
        }
    
        let index = selectedindex - 1
        self.customTabBarItems.forEach { (customtab) in
            customtab.backgroundColor = UIColor.white
        }
        self.customTabBarItems[index].backgroundColor = UIColor.green
        delegate.didSelectViewController(tabBarView: self, atIndex: index)
        self.Swipe(at: index, side: "Right")
    }
    
    
    @objc func barItemTapped(sender : UIButton) {
        var side = "Right"
        let index = tabBarButtons.index(of: sender)!
        let selected = self.tababarVC?.selectedIndex ?? 0
        if selected == index
        {
            return
        }
        if selected > index
        {
            side = "Right"
        }
        else{
            side = "Left"
        }
        self.customTabBarItems.forEach { (customtab) in
            customtab.backgroundColor = UIColor.white
        }
        self.customTabBarItems[index].backgroundColor = UIColor.green
        delegate.didSelectViewController(tabBarView: self, atIndex: index)
        self.Swipe(at: index, side: side)
    }
}
