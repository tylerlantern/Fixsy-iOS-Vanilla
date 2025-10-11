public func syncItems<Item: Comparable>(
  localItems: [Item],
  remoteItems: [Item],
  remoteItemsPageSize: Int,
  startAt startIndex: Int,
  isAscending: Bool
) -> (removeItems: [Item], saveItems: [Item]) {
  syncItems(
    localItems: localItems,
    remoteItems: remoteItems,
    remoteItemsPageSize: remoteItemsPageSize,
    startAt: startIndex,
    isAscending: isAscending,
    toComparable: { $0 }
  )
}

public func syncItems<Item, ItemComparable: Comparable>(
  localItems: [Item],
  remoteItems: [Item],
  remoteItemsPageSize: Int?,
  startAt startIndex: Int,
  isAscending: Bool,
  toComparable: @escaping (Item) -> ItemComparable
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

  var (removeItems, saveItems, localItemsCount, remoteItemsCount, localIdx, _) = syncSortedItems(
    localItems: localItems,
    remoteItems: remoteItems,
    startLocalIdx: startIndex,
    lastRemoteItem: lastRemoteItem,
    isAscending: isAscending,
    toComparable: toComparable
  )

  if let remoteItemsPageSize = remoteItemsPageSize {
    while
      localIdx < localItemsCount,
      localIdx < remoteItemsPageSize || remoteItemsCount < remoteItemsPageSize
    {
      removeItems.append(localItems[localIdx])
      localIdx += 1
    }
  }

  return (removeItems, saveItems)
}

public func syncAllItems<Item, ItemComparable: Comparable>(
  localItems: [Item],
  remoteItems: [Item],
  isAscending: Bool,
  toComparable: @escaping (Item) -> ItemComparable
) -> (removeItems: [Item], saveItems: [Item]) {
  guard !localItems.isEmpty
  else { return ([], remoteItems) }

  guard let lastRemoteItem = remoteItems.last
  else {
    return ([], [])
  }

  let (removeItems, saveItems, localItemsCount, _, localIdx, _) = syncSortedItems(
    localItems: localItems,
    remoteItems: remoteItems,
    startLocalIdx: 0,
    lastRemoteItem: lastRemoteItem,
    isAscending: isAscending,
    toComparable: toComparable
  )

  return (removeItems + localItems[localIdx ..< localItemsCount], saveItems)
}

public func syncSortedItems<Item, ItemComparable: Comparable>(
  localItems: [Item],
  remoteItems: [Item],
  startLocalIdx: Int,
  lastRemoteItem: Item,
  isAscending: Bool,
  toComparable: @escaping (Item) -> ItemComparable
)
  -> (
    removeItems: [Item],
    saveItems: [Item],
    localItemsCount: Int,
    remoteItemCount: Int,
    localIdx: Int,
    remoteIdx: Int
  )
{
  let localItemsCount = localItems.count
  let remoteItemsCount = remoteItems.count

  var removeItems: [Item] = []
  var saveItems: [Item] = []
  var localIdx = startLocalIdx
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

  return (
    removeItems,
    saveItems + remoteItems[remoteIdx ..< remoteItems.count],
    localItemsCount,
    remoteItemsCount,
    localIdx,
    remoteIdx
  )
}
