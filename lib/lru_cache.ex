defmodule LRUCache do
  @moduledoc """
  Least Recently Used (LRU) Cache
  """

  defstruct [:capacity, :cache]

  @doc """
  Initializes the cache with a capacity.
  """
  @spec init_(capacity :: integer) :: any
  def init_(capacity) do
    Agent.start_link(fn -> %__MODULE__{capacity: capacity, cache: []} end, name: __MODULE__)
  end

  @doc """
  Get the value (will always be positive) of the key if the key exists in the cache, otherwise return -1.

  ## Examples

      iex> LRUCache.get(1)
      -1

      iex> LRUCache.put(1, 1)
      :ok

      iex> LRUCache.get(1)
      1

  """
  @spec get(key :: integer) :: integer
  def get(key) do
    Agent.get_and_update(__MODULE__, fn %__MODULE__{cache: cache} = state ->
      case List.keyfind(cache, key, 0) do
        nil ->
          {-1, state}

        {_, value} ->
          {value, access_cache(state, key, value)}
      end
    end)
  end

  @doc """
  Set or insert the value if the key is not already present. When the cache reached its capacity, it should invalidate the least recently used item before inserting a new item.

  ## Examples

      iex> LRUCache.put(1, 1)
      :ok

      iex> LRUCache.put(2, 2)
      :ok

  """
  @spec put(key :: integer, value :: integer) :: any
  def put(key, value) do
    Agent.update(__MODULE__, fn %__MODULE__{} = state ->
      state
      |> check_is_overflow(key)
      |> update_cache(key, value)
    end)
  end

  defp check_is_overflow(%__MODULE__{cache: cache, capacity: capacity} = state, key) do
    if length(cache) == capacity && not List.keymember?(cache, key, 0) do
      %__MODULE__{state | cache: tl(cache)}
    else
      state
    end
  end

  defp update_cache(%__MODULE__{cache: cache} = state, key, value) do
    if List.keymember?(cache, key, 0) do
      access_cache(state, key, value)
    else
      %__MODULE__{state | cache: cache ++ [{key, value}]}
    end
  end

  defp access_cache(%__MODULE__{cache: cache} = state, key, value) do
    new_cache = List.keydelete(cache, key, 0) ++ [{key, value}]
    %__MODULE__{state | cache: new_cache}
  end
end
