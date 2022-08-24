defmodule RecordListEcto.RetrieveStep do
  @moduledoc """
  A step to retrieve the records from the repo.

  ## Options

  #{NimbleOptions.docs(RecordListEcto.Options.retrieve_options())}
  """

  @behaviour RecordList.StepBehaviour

  @impl true
  def execute(%RecordList{query: query} = record_list, :retrieve, opts) do
    opts = NimbleOptions.validate!(opts, RecordListEcto.Options.retrieve_options())
    records = opts[:repo].all(query)

    %{record_list | records: records, loaded: true}
  end
end
