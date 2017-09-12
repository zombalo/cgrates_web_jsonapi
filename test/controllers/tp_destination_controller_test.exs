defmodule CgratesWebJsonapi.TpDestinationControllerTest do
  use CgratesWebJsonapi.ConnCase

  import CgratesWebJsonapi.Factory

  alias CgratesWebJsonapi.TpDestination
  alias CgratesWebJsonapi.Repo

  setup do
    user = insert :user

    conn = build_conn()
     |> put_req_header("accept", "application/vnd.api+json")
     |> put_req_header("content-type", "application/vnd.api+json")
     |> Guardian.Plug.api_sign_in(
       user,
       :token,
       perms: %{default: [:read, :write]}
     )
    {:ok, conn: conn}
  end

  defp relationships do
    %{}
  end

  test "lists all entries related tariff plan on index", %{conn: conn} do
    tariff_plan_1 = insert :tariff_plan
    tariff_plan_2 = insert :tariff_plan

    insert :tp_destination, tpid: tariff_plan_1.alias
    insert :tp_destination, tpid: tariff_plan_2.alias

    conn = get(conn, tp_destination_path(conn, :index, tpid: tariff_plan_1.alias)) |> doc
    assert length(json_response(conn, 200)["data"]) == 1
  end

  test "returns bad request status if tpid option wasn't pass", %{conn: conn} do
    assert_error_sent 400, fn ->
      conn = get(conn, tp_destination_path(conn, :index)) |> doc
    end
  end

  test "shows chosen resource", %{conn: conn} do
    tariff_plan = insert :tariff_plan
    tp_destination = insert :tp_destination, tpid: tariff_plan.alias

    conn = get(conn, tp_destination_path(conn, :show, tp_destination)) |> doc

    data = json_response(conn, 200)["data"]
    assert data["id"] == "#{tp_destination.id}"
    assert data["type"] == "tp-destination"
    assert data["attributes"]["tpid"] == tp_destination.tpid
    assert data["attributes"]["tag"] == tp_destination.tag
    assert data["attributes"]["prefix"] == tp_destination.prefix
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get(conn, tp_destination_path(conn, :show, -1)) |> doc
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    tariff_plan = insert :tariff_plan
    params = Map.merge params_for(:tp_destination), %{tpid: tariff_plan.alias}

    conn = post(conn, tp_destination_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "tp-destinations",
        "attributes" => params,
        "relationships" => relationships
      }
    }) |> doc

    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(TpDestination, params)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, tp_destination_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "tp-destinations",
        "attributes" => %{},
        "relationships" => relationships
      }
    }

    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    tariff_plan    = insert :tariff_plan
    tp_destination = insert :tp_destination, tpid: tariff_plan.alias

    params = params_for(:tp_destination)

    conn = put(conn, tp_destination_path(conn, :update, tp_destination), %{
      "meta" => %{},
      "data" => %{
        "type" => "tp-destinations",
        "id" => tp_destination.id,
        "attributes" => params,
        "relationships" => relationships
      }
    }) |> doc

    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(TpDestination, params)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    tariff_plan    = insert :tariff_plan
    tp_destination = insert :tp_destination, tpid: tariff_plan.alias

    conn = put(conn, tp_destination_path(conn, :update, tp_destination), %{
      "meta" => %{},
      "data" => %{
        "type" => "tp-destinations",
        "id" => tp_destination.id,
        "attributes" => %{tpid: nil},
        "relationships" => relationships
      }
    }) |> doc

    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    tariff_plan    = insert :tariff_plan
    tp_destination = insert :tp_destination, tpid: tariff_plan.alias

    conn = delete(conn, tp_destination_path(conn, :delete, tp_destination)) |> doc
    assert response(conn, 204)
    refute Repo.get(TpDestination, tp_destination.id)
  end

end
