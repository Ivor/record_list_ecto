defmodule RecordListEctoTest.User do
  use Ecto.Schema

  schema "users" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
  end
end

defmodule RecordListEctoTest.TestRecordList do
  use RecordList,
    steps: [
      base: [impl: __MODULE__],
      sort: [
        impl: RecordListEcto.SortStep,
        default_sort: "email",
        default_order: "asc",
        order_keys: ["nested", "order"]
      ],
      paginate: [impl: RecordListEcto.PaginateStep, repo: __MODULE__, per_page: 10],
      retrieve: [impl: RecordListEcto.RetrieveStep, repo: __MODULE__]
    ]

  import Ecto.Query

  @behaviour RecordList.StepBehaviour
  def execute(record_list, :base, _opts) do
    %{record_list | query: from(u in RecordListEctoTest.User)}
  end

  # NOTE: Only implementing this to avoid having to build a real repo.
  def all(query), do: query

  def aggregate(query, :count, :id) do
    100
  end
end

defmodule RecordListEctoTest do
  use ExUnit.Case
  doctest RecordListEcto

  alias RecordListEctoTest.TestRecordList

  describe "sort" do
    test "will sort by default if no params are passed" do
      %{query: query} = TestRecordList.sort(%{})
      assert [%Ecto.Query.QueryExpr{expr: [asc: {{_, _, [_, :email]}, _, _}]}] = query.order_bys
    end

    test "will sort and order by the value in params" do
      %{query: query} =
        TestRecordList.sort(%{"sort" => "email", "nested" => %{"order" => "desc"}})

      assert [%Ecto.Query.QueryExpr{expr: [desc: {{_, _, [_, :email]}, _, _}]}] = query.order_bys

      %{query: query} =
        TestRecordList.sort(%{"sort" => "first_name", "nested" => %{"order" => "desc"}})

      assert [%Ecto.Query.QueryExpr{expr: [desc: {{_, _, [_, :first_name]}, _, _}]}] =
               query.order_bys
    end
  end

  describe "paginate" do
    test "will calculate the pagination values" do
      %{pagination: pagination} = TestRecordList.paginate(%{})
      assert pagination.per_page == 10
      assert pagination.current_page == 1
      assert is_nil(pagination.previous_page)
      assert pagination.next_page == 2
      assert pagination.total_pages == 10
      assert pagination.records_count == 100
      assert pagination.records_from == 1
      assert pagination.records_to == 10
      assert pagination.records_offset == 0
    end

    test "will offset and limit based on the options" do
      %{query: query} = TestRecordList.paginate(%{})

      assert [{0, :integer}] = query.offset.params
      assert [{10, :integer}] = query.limit.params

      %{query: query} = TestRecordList.paginate(%{"page" => 3})

      assert [{20, :integer}] = query.offset.params
      assert [{10, :integer}] = query.limit.params
    end
  end

  import Ecto.Query

  describe "RecordListEcto.SortStep.execute/3" do
    test "will read the values fram params based on the sort and order keys in the options." do
      record_list = %RecordList{
        query: from(u in RecordListEctoTest.User),
        params: %{
          "nested" => %{"sort" => "first_name", "order" => "desc"},
          "not_nested_sort" => "last_name",
          "not_nested_order" => "asc"
        }
      }

      %{query: query} =
        RecordListEcto.SortStep.execute(record_list, :sort,
          default_sort: "email",
          default_order: "asc",
          sort_keys: ["nested", "sort"]
        )

      assert [%Ecto.Query.QueryExpr{expr: [asc: {{_, _, [_, :first_name]}, _, _}]}] =
               query.order_bys

      %{query: query} =
        RecordListEcto.SortStep.execute(record_list, :sort,
          default_sort: "email",
          default_order: "asc",
          sort_keys: ["not_nested_sort"]
        )

      assert [%Ecto.Query.QueryExpr{expr: [asc: {{_, _, [_, :last_name]}, _, _}]}] =
               query.order_bys

      %{query: query} =
        RecordListEcto.SortStep.execute(record_list, :sort,
          default_sort: "email",
          default_order: "asc",
          sort_keys: ["nested", "sort"],
          order_keys: ["nested", "order"]
        )

      assert [%Ecto.Query.QueryExpr{expr: [desc: {{_, _, [_, :first_name]}, _, _}]}] =
               query.order_bys

      %{query: query} =
        RecordListEcto.SortStep.execute(record_list, :sort,
          default_sort: "email",
          default_order: "desc",
          sort_keys: ["not_nested_sort"],
          order_keys: ["not_nested_order"]
        )

      assert [%Ecto.Query.QueryExpr{expr: [asc: {{_, _, [_, :last_name]}, _, _}]}] =
               query.order_bys
    end

    test "will order nulls last if option is set" do
      record_list = %RecordList{
        query: from(u in RecordListEctoTest.User),
        params: %{}
      }

      %{query: query} =
        RecordListEcto.SortStep.execute(record_list, :sort,
          default_sort: "email",
          default_order: "asc",
          sort_keys: ["nested", "sort"],
          nulls_last: true
        )

      assert [%Ecto.Query.QueryExpr{expr: [asc_nulls_last: {{_, _, [_, :email]}, _, _}]}] =
               query.order_bys
    end
  end

  describe "RecordListEcto.PaginateStep.execute/3" do
    test "will read the page from default params if no option is passed" do
      record_list = %RecordList{
        query: from(u in RecordListEctoTest.User),
        params: %{"nested" => %{"page" => "3"}, "page" => 2}
      }

      %{query: query} =
        RecordListEcto.PaginateStep.execute(record_list, :paginate,
          repo: RecordListEctoTest.TestRecordList,
          per_page: 10
        )

      assert [{10, :integer}] = query.offset.params
      assert [{10, :integer}] = query.limit.params

      %{query: query} =
        RecordListEcto.PaginateStep.execute(record_list, :paginate,
          repo: RecordListEctoTest.TestRecordList,
          per_page: 20,
          page_keys: ["nested", "page"]
        )

      assert [{40, :integer}] = query.offset.params
      assert [{20, :integer}] = query.limit.params
    end

    test "will try to aggregate by the value in `count_by` if passed" do
      record_list = %RecordList{
        query: from(u in RecordListEctoTest.User),
        params: %{"nested" => %{"page" => "3"}, "page" => 2}
      }

      assert_raise FunctionClauseError,
                   "no function clause matching in RecordListEctoTest.TestRecordList.aggregate/3",
                   fn ->
                     %{query: query} =
                       RecordListEcto.PaginateStep.execute(record_list, :paginate,
                         repo: RecordListEctoTest.TestRecordList,
                         per_page: 10,
                         count_by: :not_id
                       )
                   end
    end

    test "will allow overriding per_page via params" do
      record_list = %RecordList{
        query: from(u in RecordListEctoTest.User),
        params: %{"nested" => %{"page" => "3", "per_page_key" => 5}, "page" => 2}
      }

      %{query: query} =
        RecordListEcto.PaginateStep.execute(record_list, :paginate,
          repo: RecordListEctoTest.TestRecordList,
          per_page: 10,
          per_page_keys: ["nested", "per_page_key"]
        )

      assert [{5, :integer}] = query.offset.params
      assert [{5, :integer}] = query.limit.params
    end
  end
end
