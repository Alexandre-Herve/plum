defmodule Plum.Sales.Prospect do
  use Ecto.Schema
  import Ecto.Changeset

  alias Plum.Geo.{
    City,
    Land,
  }

  alias Plum.Sales.{
    Contact,
    Prospect,
    ProspectLand,
  }

  schema "sales_prospects" do
    field :max_budget, :integer
    field :land_budget, :integer
    field :notes, :string
    field :origin, :string
    field :status, :string, default: "new"
    has_one :contact, Contact
    many_to_many :cities, City,
      join_through: "sales_prospects_geo_cities",
      join_keys: [sales_prospect_id: :id, geo_city_id: :id],
      on_replace: :delete
    many_to_many :lands, Land,
      join_through: ProspectLand,
      join_keys: [prospect_id: :id, land_id: :id],
      on_replace: :delete
    timestamps()
  end

  @required_fields ~w(
  )a

  @optional_fields ~w(
    max_budget
    land_budget
    notes
    origin
    status
  )a

  @possible_status ~w(
    new
    in_progress
    rejected
    signed
    duplicate
  )

  @doc false
  def changeset(%Prospect{} = prospect, attrs) do
    prospect
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:status, @possible_status)
  end
end