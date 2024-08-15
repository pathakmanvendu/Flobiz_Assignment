//
//  CarouselViewController.swift
//  Vought Showcase
//
//  Created by Burhanuddin Rampurawala on 06/08/24.
//

import Foundation
import UIKit


final class CarouselViewController: UIViewController, SegmentedProgressBarDelegate {
    func segmentedProgressBarChangedIndex(index: Int) {
        currentItemIndex = index
        let controller = getController(at: index)
        pageViewController?.setViewControllers([controller], direction: .forward, animated: true, completion: nil)
    }
    
    func segmentedProgressBarFinished() {
        print("story finished")
    }
    
    /// Container view for the carousel
    @IBOutlet private weak var containerView: UIView!
    
    /// Carousel control with page indicator
   // @IBOutlet private weak var carouselControl: UIPageControl!


    private var segmentedProgressBar: SegmentedProgressBar!
    
    /// Page view controller for carousel
    private var pageViewController: UIPageViewController?
    
    /// Carousel items
    private var items: [CarouselItem] = []
     var currentItemIndex: Int = 0

    /// Initializer
    /// - Parameter items: Carousel items
    public init(items: [CarouselItem]) {
        self.items = items
        super.init(nibName: "CarouselViewController", bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initPageViewController()
      //  initCarouselControl()
        initSegmentedProgressBar()
        setupTapGesture()
    }
    
    private func setupTapGesture() {
        let leftTapGesture = UITapGestureRecognizer(target: self, action: #selector(leftSideTap))
        let rightTapGesture = UITapGestureRecognizer(target: self, action: #selector(rightSideTap))
        
        let screenWidth = view.bounds.width
        let screenHeight = view.bounds.height
        
        let leftTapArea = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth / 3, height: screenHeight))
        let rightTapArea = UIView(frame: CGRect(x: screenWidth * 2 / 3, y: 0, width: screenWidth / 3, height: screenHeight))
        
        
        leftTapArea.backgroundColor = UIColor.clear
        rightTapArea.backgroundColor = UIColor.clear
        
        leftTapArea.addGestureRecognizer(leftTapGesture)
        rightTapArea.addGestureRecognizer(rightTapGesture)
            
        view.addSubview(leftTapArea)
        view.addSubview(rightTapArea)
    }
    
    @objc func  leftSideTap() {
        let previousIndex = (currentItemIndex - 1 + items.count) % items.count
        let controller = getController(at: previousIndex)
        pageViewController?.setViewControllers([controller], direction: .reverse, animated: true, completion: nil)
        currentItemIndex = previousIndex
        segmentedProgressBar.rewind()
    }
    
    @objc func rightSideTap() {
        let nextIndex = (currentItemIndex + 1) % items.count
        let controller = getController(at: nextIndex)
        pageViewController?.setViewControllers([controller], direction: .forward, animated: true, completion: nil)
        currentItemIndex = nextIndex
        segmentedProgressBar.skip()
    }
    
    
    /// Initialize page view controller
    private func initPageViewController() {

        // Create pageViewController
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal,
        options: nil)

        // Set up pageViewController
        pageViewController?.dataSource = self
        pageViewController?.delegate = self
        pageViewController?.setViewControllers(
            [getController(at: currentItemIndex)], direction: .forward, animated: false)

        pageViewController?.disableSwipeGesture()
        guard let theController = pageViewController else {
            return
        }
        
        // Add pageViewController in container view
        add(asChildViewController: theController,
            containerView: containerView)
    }
    

     private func initSegmentedProgressBar(){
        segmentedProgressBar = SegmentedProgressBar(numberOfSegments: items.count, duration: 5.0)
        segmentedProgressBar.delegate = self
        
        segmentedProgressBar.frame = CGRect(x: 20, y: view.safeAreaInsets.top + 60, width: view.frame.width - 40, height: 4)
        view.addSubview(segmentedProgressBar)
        
        segmentedProgressBar.startAnimation()
    }
    
   
    
    func updatePageController() {
        let controller = getController(at: currentItemIndex)
        pageViewController?.setViewControllers([controller], direction: .forward, animated: false, completion: nil)
    }


    /// Update current page
    /// Parameter sender: UIPageControl
    @objc func updateCurrentPage(sender: UIPageControl) {
        // Get direction of page change based on current item index
        let direction: UIPageViewController.NavigationDirection = sender.currentPage > currentItemIndex ? .forward : .reverse
        
        // Get controller for the page
        let controller = getController(at: sender.currentPage)
        
        // Set view controller in pageViewController
        pageViewController?.setViewControllers([controller], direction: direction, animated: true, completion: nil)
        
        // Update current item index
        currentItemIndex = sender.currentPage
    }
    
    /// Get controller at index
    /// - Parameter index: Index of the controller
    /// - Returns: UIViewController
    private func getController(at index: Int) -> UIViewController {
        return items[index].getController()
    }

}

// MARK: UIPageViewControllerDataSource methods
extension CarouselViewController: UIPageViewControllerDataSource {
    
    /// Get previous view controller
    /// - Parameters:
    ///  - pageViewController: UIPageViewController
    ///  - viewController: UIViewController
    /// - Returns: UIViewController
    public func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController) -> UIViewController? {
            
            // Check if current item index is first item
            // If yes, return last item controller
            // Else, return previous item controller
            if currentItemIndex == 0 {
                return items.last?.getController()
            }
            return getController(at: currentItemIndex-1)
        }

    /// Get next view controller
    /// - Parameters:
    ///  - pageViewController: UIPageViewController
    ///  - viewController: UIViewController
    /// - Returns: UIViewController
    public func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController) -> UIViewController? {
           
            // Check if current item index is last item
            // If yes, return first item controller
            // Else, return next item controller
            if currentItemIndex + 1 == items.count {
                return items.first?.getController()
            }
            return getController(at: currentItemIndex + 1)
        }
}

// MARK: UIPageViewControllerDelegate methods
extension CarouselViewController: UIPageViewControllerDelegate {
    
    /// Page view controller did finish animating
    /// - Parameters:
    /// - pageViewController: UIPageViewController
    /// - finished: Bool
    /// - previousViewControllers: [UIViewController]
    /// - completed: Bool
    public func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool) {
            if completed,
               let visibleViewController = pageViewController.viewControllers?.first,
               let index = items.firstIndex(where: { $0.getController() == visibleViewController }){
                currentItemIndex = index
            }
        }
}
