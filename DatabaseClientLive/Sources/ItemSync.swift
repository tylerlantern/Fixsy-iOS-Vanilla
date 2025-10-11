import Foundation

func synchronizeItems<Item: Comparable>(
  localItems: [Item],
  remoteItems: [Item],
  startAt startIndex: Int,
  isAscending: Bool = true
) -> (removeItems: [Item], saveItems: [Item]) {
  synchronizeItems(
    localItems: localItems,
    remoteItems: remoteItems,
    startAt: startIndex,
    toComparable: { $0 },
    isAscending: isAscending
  )
}

func synchronizeItems<Item, ItemComparable: Comparable>(
  localItems: [Item],
  remoteItems: [Item],
  startAt startIndex: Int,
  toComparable: @escaping (Item) -> ItemComparable,
  isAscending: Bool = true
) -> (removeItems: [Item], saveItems: [Item]) {
  guard !localItems.isEmpty
  else { return ([], remoteItems) }

  guard let lastRemoteItem = remoteItems.last
  else {
    if startIndex < localItems.count {
      return (Array(localItems[startIndex ..< localItems.count]), [])
    }
    return ([], [])
  }

  let localItemsCount = localItems.count
  let remoteItemsCount = remoteItems.count

  var removeItems: [Item] = []
  var saveItems: [Item] = []
  var localIdx = startIndex
  var remoteIdx = 0

  let lte: (Item, Item) -> Bool = {
    if isAscending {
      return toComparable($0) <= toComparable($1)
    } else {
      return toComparable($1) <= toComparable($0)
    }
  }

  let lt: (Item, Item) -> Bool = {
    if isAscending {
      return toComparable($0) < toComparable($1)
    } else {
      return toComparable($1) < toComparable($0)
    }
  }

  let gt: (Item, Item) -> Bool = {
    if isAscending {
      return toComparable($0) > toComparable($1)
    } else {
      return toComparable($1) > toComparable($0)
    }
  }

  while
    localIdx < localItemsCount,
    remoteIdx < remoteItemsCount,
    lte(localItems[localIdx], lastRemoteItem)
  {
    let localItem = localItems[localIdx]
    let remoteItem = remoteItems[remoteIdx]

    if lt(localItem, remoteItem) {
      removeItems.append(localItem)
      localIdx += 1
    } else if gt(localItem, remoteItem) {
      saveItems.append(remoteItem)
      remoteIdx += 1
    } else {
      saveItems.append(remoteItem)
      localIdx += 1
      remoteIdx += 1
    }
  }

  return (removeItems, saveItems + remoteItems[remoteIdx ..< remoteItems.count])
}
