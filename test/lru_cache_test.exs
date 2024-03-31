defmodule LRUCacheTest do
  use ExUnit.Case
  doctest LRUCache

  describe "LRUCache" do
    test "case 1" do
      # ["LRUCache", "put", "put", "get", "put", "get", "put", "get", "get", "get"]
      # [[2], [1, 1], [2, 2], [1], [3, 3], [2], [4, 4], [1], [3], [4]]

      LRUCache.init_(2)

      assert LRUCache.put(1, 1) == :ok
      assert LRUCache.put(2, 2) == :ok
      # [1, {2,2}] should be [{2,2}, {1,1}]
      assert LRUCache.get(1) == 1
      assert LRUCache.put(3, 3) == :ok
      assert LRUCache.get(2) == -1
      assert LRUCache.put(4, 4) == :ok
      assert LRUCache.get(1) == -1
      assert LRUCache.get(3) == 3
      assert LRUCache.get(4) == 4
    end

    test "case 2" do
      ["LRUCache", "put", "get", "put", "get", "get"]
      [[1], [2, 1], [2], [3, 2], [2], [3]]

      LRUCache.init_(1)

      assert LRUCache.put(2, 1) == :ok
      assert LRUCache.get(2) == 1
      assert LRUCache.put(3, 2) == :ok
      assert LRUCache.get(2) == -1
      assert LRUCache.get(3) == 2
    end
  end
end
