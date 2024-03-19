# LuaDS
A collection of data structures written in Lua.

## Available Structures
- `List` (virtual) - sequential value container
  - `ArrayList` - list backed by an array
  - `LinkedList` - list backed by a double-linked list
  - `Deque` - list backed by a moving-start array/hashmap
- `Map` (virtual) - key-value mapped container
  - `OrderedMap` - map backed by a red-black tree, iterator sorts keys in order
  - `ListMap` - map backed by two tables (one for key->order, one for order->value), iterator sorts by when items were added
  - `UnorderedMap` - map backed by a hashmap table, iterator is unsorted
  - `TrieMap` - map backed by a trie, iterator sorts keys alphabetically
- `BST` - binary search tree
  - `AVLTree` - self-balancing AVL BST
  - `RedBlackTree` - self-balancing red-black tree
- `Heap` - min-/max-heap sorted removal container
- `Queue` - first-in, first-out queue backed by any `List` type
  - `PriorityQueue` - first-in, usually-first-out queue with priority levels, backed by a max-heap
- `Stack` - first-in, last-out stack backed by any `List` type
- `Trie` - prefix tree for strings, for text prediction

## License
MIT
