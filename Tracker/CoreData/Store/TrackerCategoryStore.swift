import CoreData

struct TrackerCategoryStoreUpdate {
    let insertedIndices: [IndexPath]
    let deletedIndices: [IndexPath]
    let updatedIndices: [IndexPath]
    let movedIndices: [(from: IndexPath, to: IndexPath)]
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerCategoryStoreUpdate)
}

protocol TrackerCategoryStoreProtocol {
    var numberOfSections: Int { get }
    func numberOfItemsInSection(_ section: Int) -> Int
    func addCategory(_ name: String)
}

final class TrackerCategoryStore: NSObject {
    private weak var delegate: TrackerCategoryStoreDelegate?
    
    private let dataController = DataController.shared
    private let context = DataController.shared.context
    
    private var insertedIndices: [IndexPath] = []
    private var deletedIndices: [IndexPath] = []
    private var updatedIndices: [IndexPath] = []
    private var movedIndices: [(from: IndexPath, to: IndexPath)] = []
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    init(delegate: TrackerCategoryStoreDelegate) {
        self.delegate = delegate
    }
}

// MARK: - TrackerCategoryStoreProtocol
extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func addCategory(_ name: String) {
        let category = TrackerCategoryCoreData(context: context)
        category.name = name
        dataController.saveContext()
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndices.removeAll()
        deletedIndices.removeAll()
        updatedIndices.removeAll()
        movedIndices.removeAll()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath {
                deletedIndices.append(indexPath)
            }
        case .insert:
            if let newIndexPath {
                insertedIndices.append(newIndexPath)
            }
        case .update:
            if let indexPath {
                updatedIndices.append(indexPath)
            }
        case .move:
            if let oldIndexPath = indexPath, let newIndexPath = newIndexPath {
                movedIndices.append((from: oldIndexPath, to: newIndexPath))
            }
        @unknown default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let update = TrackerCategoryStoreUpdate(
            insertedIndices: insertedIndices,
            deletedIndices: deletedIndices,
            updatedIndices: updatedIndices,
            movedIndices: movedIndices
        )
        delegate?.didUpdate(update)
    }
}
