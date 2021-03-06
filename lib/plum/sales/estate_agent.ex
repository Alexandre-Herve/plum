defmodule Plum.Sales.EstateAgent do
  use Ecto.Schema
  import Ecto.Changeset

  alias Plum.Geo.{
    Land,
  }

  alias Plum.Sales.{
    EstateAgent,
    Contact,
  }

  schema "sales_estate_agents" do
    field :notes, :string
    field :evaluation, :string
    has_one :contact, Contact
    has_many :lands, Land
    timestamps()
  end

  @required_fields ~w(
  )a

  @optional_fields ~w(
    notes
    evaluation
  )a

  @evaluations ~w(
    miser
    share_location
    share_and_visit
  )

  @doc false
  def changeset(%EstateAgent{} = estate_agent, attrs) do
    estate_agent
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:evaluation, @evaluations)
  end
end
