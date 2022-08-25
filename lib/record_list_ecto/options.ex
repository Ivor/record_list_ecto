defmodule RecordListEcto.Options do
  @moduledoc """
  Builds `NimbleOptions` options specifications.
  """

  @sort_options NimbleOptions.new!(
                  default_sort: [
                    type: :string,
                    required: true,
                    doc: "The default value for sorting if none are present in the params."
                  ],
                  default_order: [
                    type: :string,
                    required: true,
                    doc: "The default value for ordering if none are present in the params."
                  ],
                  nulls_last: [
                    type: :boolean,
                    required: false,
                    default: false,
                    doc: "Determine wether sorting should put null values last. Default to false."
                  ],
                  sort_keys: [
                    type: {:list, :string},
                    required: false,
                    default: ["sort"],
                    doc: "The path to be passed to `get_in/2` to extract the sort parameter"
                  ],
                  order_keys: [
                    type: {:list, :string},
                    required: false,
                    default: ["order"],
                    doc: "The path to be passed to `get_in/2` to extract the order parameter"
                  ]
                )

  @doc """
  Options spec for `RecordListEcto.SortStep`
  """
  def sort_options() do
    @sort_options
  end

  @paginate_options NimbleOptions.new!(
                      repo: [
                        type: :atom,
                        required: true,
                        doc: "The module to be used for calling `aggregate/4` on."
                      ],
                      count_by: [
                        required: false,
                        type: :atom,
                        default: :id,
                        doc:
                          "The field by which to count the number of records that match the query."
                      ],
                      page_keys: [
                        type: {:list, :string},
                        required: false,
                        default: ["page"],
                        doc:
                          "The path to be passed to `get_in/2` to extract the page number parameter"
                      ],
                      per_page_keys: [
                        type: {:list, :string},
                        required: false,
                        default: ["per_page"],
                        doc:
                          "The path to be passed to `get_in/2` to extract the number of records per page"
                      ],
                      per_page: [
                        required: true,
                        type: :integer,
                        doc: "The number of records to be returned per page."
                      ]
                    )

  @doc """
  Options spec for `RecordListEcto.PaginateStep`
  """
  def paginate_options() do
    @paginate_options
  end

  @retrieve_options NimbleOptions.new!(
                      repo: [
                        required: true,
                        type: :atom,
                        doc:
                          "The Ecto.Repo to use when calling `all/1` with the query in the record list."
                      ]
                    )

  @doc """
  Options spec for `RecordListEcto.RetrieveStep`
  """
  def retrieve_options() do
    @retrieve_options
  end
end
