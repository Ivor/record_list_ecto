defmodule RecordListEcto.PaginateStep do
  @moduledoc """
  Apply simple pagination (offset and limit) to a query.

  ## Options

  #{NimbleOptions.docs(RecordListEcto.Options.paginate_options())}
  """
  import Ecto.Query

  @behaviour RecordList.StepBehaviour

  @impl true
  def execute(%RecordList{query: query, params: params} = record_list, :paginate, opts) do
    opts = NimbleOptions.validate!(opts, RecordListEcto.Options.paginate_options())

    count = opts[:repo].aggregate(query, :count, opts[:count_by])
    current_page = get_in(params, opts[:page_keys])
    per_page = get_in(params, opts[:per_page_keys]) || opts[:per_page]

    %{records_offset: offset} =
      pagination = RecordList.Pagination.build(current_page, per_page, count)

    new_query =
      query
      |> offset(^offset)
      |> limit(^per_page)

    %{record_list | query: new_query, pagination: pagination}
  end
end
