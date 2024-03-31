defmodule LRUCache do
  defstruct [:capacity, :cache]

  @spec init_(capacity :: integer) :: any
  def init_(capacity) do
    Agent.start_link(fn -> %__MODULE__{capacity: capacity, cache: []} end, name: __MODULE__)
  end

  @spec get(key :: integer) :: integer
  def get(key) do
    Agent.get_and_update(__MODULE__, fn %__MODULE__{cache: cache} = state ->
      case List.keyfind(cache, key, 0) do
        nil ->
          {-1, state}

        {_, value} ->
          delete = List.keydelete(cache, key, 0)
          new_cache = delete ++ [{key, value}]
          {value, %__MODULE__{state | cache: new_cache}}
      end
    end)
  end

  @spec put(key :: integer, value :: integer) :: any
  def put(key, value) do
    Agent.update(__MODULE__, fn state ->
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
      new_cache = List.keydelete(cache, key, 0) ++ [{key, value}]
      %__MODULE__{state | cache: new_cache}
    else
      %__MODULE__{state | cache: cache ++ [{key, value}]}
    end
  end
end
