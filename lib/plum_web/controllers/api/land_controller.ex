defmodule PlumWeb.Api.LandController do
  use PlumWeb, :controller
  alias Plum.Repo
  alias Plum.Geo
  alias Plum.Geo.Land

  action_fallback PlumWeb.FallbackController

  def index(conn, params) do
    lands_query = Geo.list_lands_query(params)
    page = lands_query |> Repo.paginate(params)

    render conn, "index.json",
      lands: page.entries,
      page_number: page.page_number,
      total_pages: page.total_pages
  end

  def create(conn, %{"land" => land_params}) do
    with {:ok, %Land{} = land} <- Geo.create_land(land_params) do
      land = land |> Repo.preload([:ads, :city, [estate_agent: :contact]], force: true)
      conn
      |> put_status(:created)
      |> put_resp_header("location", api_land_path(conn, :show, land))
      |> render("show.json", land: land)
    end
  end

  def show(conn, %{"id" => id}) do
    land = Geo.get_land!(id)
    render(conn, "show.json", land: land)
  end

  def update(conn, %{"id" => id, "land" => land_params}) do
    land = Geo.get_land!(id)
    with {:ok, %Land{} = land} <- Geo.update_land(land, land_params) do
      land = land |> Repo.preload([:ads, :city, [estate_agent: :contact]], force: true)
      render(conn, "show.json", land: land)
    end
  end

  def delete(conn, %{"id" => id}) do
    land = Geo.get_land!(id)
    with {:ok, %Land{}} <- Geo.delete_land(land) do
      conn |> render(PlumWeb.Api.SuccessView, "deleted.json")
    end
  end
end


