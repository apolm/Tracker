import Foundation

protocol CategoriesViewModelProtocol {
    var onDataChanged: (() -> Void)? { get set }
    
    var categoriesIsEmpty: Bool { get }
    var numberOfSections: Int { get }
    func numberOfCategories(_ section: Int) -> Int
    func category(at indexPath: IndexPath) -> TrackerCategory
    func didSelectRowAt(indexPath: IndexPath)
}

protocol CategorySelectionDelegate {
    func didSelectCategory(_ name: String)
}

final class CategoriesViewModel: CategoriesViewModelProtocol {
    private lazy var model: TrackerCategoryStoreProtocol = {
        TrackerCategoryStore(delegate: self)
    }()
    
    var delegate: CategorySelectionDelegate?
    
    var onDataChanged: (() -> Void)?
    
    var categoriesIsEmpty: Bool {
        model.numberOfSections == 0 || (numberOfCategories(0) == 0)
    }
    
    var numberOfSections: Int {
        model.numberOfSections
    }
    
    func numberOfCategories(_ section: Int) -> Int {
        model.numberOfItemsInSection(section)
    }
    
    func category(at indexPath: IndexPath) -> TrackerCategory {
        let name = model.categoryName(at: indexPath)
        return TrackerCategory(name: name, trackers: [])
    }
    
    func didSelectRowAt(indexPath: IndexPath) {
        let name = model.categoryName(at: indexPath)
        delegate?.didSelectCategory(name)
    }
}

extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func didUpdate(_ update: TrackerCategoryStoreUpdate) {
        onDataChanged?()
    }
}
