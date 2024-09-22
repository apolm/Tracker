import UIKit

final class OnboardingViewController: UIPageViewController {
    // MARK: - Private Properties
    private lazy var pages: [UIViewController] = {
        let onCompletion: () -> Void = { [weak self] in
            self?.finishOnboarding()
        }
        
        let first = OnboardingPage()
        first.config(text: NSLocalizedString("onboarding.description.one", comment: "Onboarding description (first screen)"),
                     background: UIImage(named: "Background1") ?? UIImage(),
                     onCompletion: onCompletion)
        
        let second = OnboardingPage()
        second.config(text: NSLocalizedString("onboarding.description.two", comment: "Onboarding description (second screen)"),
                      background: UIImage(named: "Background2") ?? UIImage(),
                      onCompletion: onCompletion)
        
        return [first, second]
    }()
    
    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .ypBlack
        pageControl.pageIndicatorTintColor = .ypBlack.withAlphaComponent(0.3)
        pageControl.isUserInteractionEnabled = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        setupViews()
        setupConstraints()
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        view.addSubview(pageControl)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134)
        ])
    }
    
    private func finishOnboarding() {
        UserDefaults.standard.hasCompletedOnboarding = true
        
        if let window = view.window {
            window.rootViewController = TabBarController()
        }
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else { return nil }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < pages.count else { return nil }
        
        return pages[nextIndex]
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
