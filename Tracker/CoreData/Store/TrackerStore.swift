import UIKit
import CoreData

struct TrackerStoreUpdate {
    let insertedSections: [Int]
    let deletedSections: [Int]
    let insertedIndices: [IndexPath]
    let deletedIndices: [IndexPath]
    let updatedIndices: [IndexPath]
    let movedIndices: [(from: IndexPath, to: IndexPath)]
}

struct TrackerCompletion {
    let tracker: Tracker
    let numberOfCompletions: Int
    let isCompleted: Bool
}

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
}

protocol TrackerStoreProtocol {
    var isEmpty: Bool { get }
    
    var numberOfSections: Int { get }
    func numberOfItemsInSection(_ section: Int) -> Int
    func sectionName(for section: Int) -> String
    
    func addTracker(_ tracker: Tracker)
    func deleteTracker(at indexPath: IndexPath)
    
    func completionStatus(for indexPath: IndexPath) -> TrackerCompletion
}

final class TrackerStore: NSObject {
    private weak var delegate: TrackerStoreDelegate?
    private var date: Date
    
    private let dataController = DataController.shared
    private let context = DataController.shared.context
    
    private var insertedSections: [Int] = []
    private var deletedSections: [Int] = []
    private var insertedIndices: [IndexPath] = []
    private var deletedIndices: [IndexPath] = []
    private var updatedIndices: [IndexPath] = []
    private var movedIndices: [(from: IndexPath, to: IndexPath)] = []
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "category.name", ascending: true),
                                        NSSortDescriptor(key: "name", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: "category.name",
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    init(delegate: TrackerStoreDelegate, for date: Date) {
        self.delegate = delegate
        self.date = date
    }
    
    private func category() -> TrackerCategoryCoreData {
        // До реализации экрана с категориями используется единственная категория
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        let result = try? context.fetch(request)
        if let result,
           !result.isEmpty {
            return result[0]
        } else {
            let category = TrackerCategoryCoreData(context: context)
            category.name = "Общая категория"
            dataController.saveContext()
            return category
        }
    }
}

// MARK: - TrackerStoreProtocol
extension TrackerStore: TrackerStoreProtocol {
    var isEmpty: Bool {
        if let fetchedObjects = fetchedResultsController.fetchedObjects {
            return fetchedObjects.isEmpty
        } else {
            return true
        }
    }
    
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func sectionName(for section: Int) -> String {
        return fetchedResultsController.sections?[section].name ?? ""
    }
    
    func addTracker(_ tracker: Tracker) {
        let category = category()
        
        let trackerCoreData = TrackerCoreData(context: context)
        
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.colorHex = tracker.color.toHex()
        trackerCoreData.daysRaw = tracker.days?.toRawString() ?? ""
        trackerCoreData.category = category
        
        dataController.saveContext()
    }
    
    func deleteTracker(at indexPath: IndexPath) {
        
    }
    
    func completionStatus(for indexPath: IndexPath) -> TrackerCompletion {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        
        let tracker = Tracker(id: trackerCoreData.id ?? UUID(),
                              name: trackerCoreData.name ?? "",
                              color: UIColor(hex: trackerCoreData.colorHex ?? "#000000") ?? .clear,
                              emoji: trackerCoreData.emoji ?? "",
                              days: Set(rawValue: trackerCoreData.daysRaw))
        
        let isCompleted = trackerCoreData.records?.contains { record in
            guard let trackerRecord = record as? TrackerRecordCoreData else { return false }
            return trackerRecord.date == date
        } ?? false
        
        let trackerCompletion = TrackerCompletion(tracker: tracker,
                                                  numberOfCompletions: trackerCoreData.records?.count ?? 0,
                                                  isCompleted: isCompleted)
        return trackerCompletion
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedSections.removeAll()
        deletedSections.removeAll()
        insertedIndices.removeAll()
        deletedIndices.removeAll()
        updatedIndices.removeAll()
        movedIndices.removeAll()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            insertedSections.append(sectionIndex)
        case .delete:
            deletedSections.append(sectionIndex)
        default:
            break
        }
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
        let update = TrackerStoreUpdate(
            insertedSections: insertedSections,
            deletedSections: deletedSections,
            insertedIndices: insertedIndices,
            deletedIndices: deletedIndices,
            updatedIndices: updatedIndices,
            movedIndices: movedIndices
        )
        delegate?.didUpdate(update)
    }
}
