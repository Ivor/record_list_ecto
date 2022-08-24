defmodule RecordListEcto.SortStep do
  @moduledoc """
  Apply sorting and ordering to a query.

  ## Options

  #{NimbleOptions.docs(RecordListEcto.Options.sort_options())}
  """

  import Ecto.Query

  @behaviour RecordList.StepBehaviour

  @impl true
  def execute(%RecordList{params: params, query: query} = record_list, :sort, opts) do
    sort = get_sort(params, opts)
    order = get_order(params, opts)

    new_query = query |> order_by([{^order, ^sort}])

    %{record_list | query: new_query}
  end

  defp get_sort(params, opts) do
    path = Keyword.get(opts, :sort_keys, ["sort"])

    (get_in(params, path) || Keyword.fetch!(opts, :default_sort))
    |> binary_to_atom()
  end

  defp get_order(params, opts) do
    path = Keyword.get(opts, :order_keys, ["order"])

    (get_in(params, path) || Keyword.fetch!(opts, :default_order))
    |> binary_to_atom()
    |> maybe_nulls_last(opts)
  end

  defp maybe_nulls_last(order, opts) do
    if Keyword.get(opts, :nulls_last) do
      order_nulls_last(order)
    else
      order
    end
  end

  defp binary_to_atom(order) when is_atom(order) do
    order
  end

  defp binary_to_atom(order) when is_binary(order) do
    String.to_existing_atom(order)
  end

  defp order_nulls_last(:asc), do: :asc_nulls_last
  defp order_nulls_last(:desc), do: :desc_nulls_last
end
